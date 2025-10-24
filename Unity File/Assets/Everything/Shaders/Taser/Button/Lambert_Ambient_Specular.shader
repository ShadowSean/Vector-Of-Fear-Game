Shader "Alvaro/URP/SimpleDiffuseWithAmbientAndSpecularURP"
{
    Properties
    {
        // Base color tint for the object
        _BaseColor ("Base Color", Color) = (1, 1, 1, 1)

        // Texture applied on the surface (albedo)
        _MainTex ("Base Texture", 2D) = "white" {}

        // Specular highlight color
        _SpecColor ("Specular Color", Color) = (1, 1, 1, 1)

        // Controls the sharpness of specular highlights
        _Shininess ("Shininess", Range(0.1, 100)) = 16
    }

    SubShader
    {
        // Defines how URP handles rendering
        Tags { 
            "RenderPipeline" = "UniversalRenderPipeline"
            "RenderType" = "Opaque"
        }

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            // Include URP helper libraries for lighting and math
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;  // Vertex position
                float3 normalOS   : NORMAL;    // Surface normal
                float2 uv         : TEXCOORD0; // UV coordinates
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION; // Screen position
                float3 normalWS    : TEXCOORD1;   // Normal in world space
                float3 viewDirWS   : TEXCOORD2;   // View direction in world space
                float2 uv          : TEXCOORD0;   // Texture UVs
            };

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            CBUFFER_START(UnityPerMaterial)
                float4 _BaseColor;
                float4 _SpecColor;
                float  _Shininess;
            CBUFFER_END


            // Vertex Shader
            Varyings vert (Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.normalWS = normalize(TransformObjectToWorldNormal(IN.normalOS));

                float3 worldPos = TransformObjectToWorld(IN.positionOS.xyz);
                OUT.viewDirWS = normalize(GetCameraPositionWS() - worldPos);

                OUT.uv = IN.uv;
                return OUT;
            }


            // Fragment Shader
            half4 frag (Varyings IN) : SV_Target
            {
                // --- Sample texture and prepare lighting vectors ---
                half4 texColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv);
                Light mainLight = GetMainLight();
                half3 lightDir = normalize(mainLight.direction);
                half3 normalWS = normalize(IN.normalWS);

                // --- Diffuse (Lambert) ---
                half NdotL = saturate(dot(normalWS, lightDir));
                half3 diffuse = texColor.rgb * _BaseColor.rgb * NdotL;

                // --- Ambient (soft indirect light) ---
                half3 ambient = SampleSH(normalWS) * texColor.rgb * _BaseColor.rgb;

                // --- Specular (Phong reflection) ---
                half3 reflectDir = reflect(-lightDir, normalWS);
                half3 viewDir = normalize(IN.viewDirWS);
                half specFactor = pow(saturate(dot(reflectDir, viewDir)), _Shininess);
                half3 specular = _SpecColor.rgb * specFactor;

                // --- Combine final result ---
                half3 finalColor = diffuse + ambient + specular;
                return half4(finalColor, 1.0);
            }

            ENDHLSL
        }
    }
}
