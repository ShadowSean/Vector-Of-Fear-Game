Shader "Custom/ToggleShader"
{
    Properties
    {
        // Base color tint for the surface
        _BaseColor ("Base Color", Color) = (1, 1, 1, 1)

        // Base texture (albedo)
        _MainTex ("Base Texture", 2D) = "white" {}

        // Specular reflection color
        _SpecColor ("Specular Color", Color) = (1, 1, 1, 1)

        // Controls highlight sharpness
        _Shininess ("Shininess", Range(0.1, 100)) = 16

        // Normal or bump map for surface detail
        _myBump ("Bump Texture", 2D) = "bump" {}
        _mySlider ("Bump Amount", Range(0,10)) = 1

        // Controls rim light falloff — higher = sharper edge
        _RimPower ("Rim Power", Range(0.5, 8.0)) = 3.0

        // Controls overall rim light brightness
        _RimIntensity ("Rim Intensity", Range(0.0, 10.0)) = 0

        // Toggles to enable or disable lighting components
        [Toggle] _UseDiffuse ("Enable Diffuse", Float) = 1
        [Toggle] _UseAmbient ("Enable Ambient", Float) = 1
        [Toggle] _UseSpecular ("Enable Specular", Float) = 1
        [Toggle] _UseBhong ("Enable Bump", Float) = 1
        [Toggle] _UseRim ("Enable Rim", Float) = 1
    }

    SubShader
    {
        // Tells Unity this shader is meant for URP and should render opaque geometry
        Tags { 
            "RenderPipeline" = "UniversalRenderPipeline"
            "RenderType" = "Opaque"
        }

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            // Include URP helper files that contain lighting and transform functions
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"


            //  Vertex Input (from the mesh)
            struct Attributes
            {
                float4 positionOS : POSITION; // Object-space vertex position
                float3 normalOS : NORMAL;     // Object-space surface normal
                float2 uv : TEXCOORD0;        // UV coordinates for textures
                float4 tangentOS : TANGENT;   // Tangent for normal mapping
            };


            //  Data passed to the Fragment Shader
            struct Varyings
            {
                float4 positionHCS : SV_POSITION; // Homogeneous clip-space position
                float3 normalWS : TEXCOORD1;      // Normal in world space
                float3 tangentWS : TEXCOORD2;     // Tangent in world space
                float2 uv : TEXCOORD0;            // UV coordinates passed through
                float3 bitangentWS : TEXCOORD3;   // Bitangent, used to form TBN matrix
                float3 viewDirWS : TEXCOORD4;     // Direction from fragment to camera
            };


            //  Textures and Samplers
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            TEXTURE2D(_myBump);
            SAMPLER(sampler_myBump);


            //  Material Properties (URP Batcher)
            CBUFFER_START(UnityPerMaterial)
                float4 _BaseColor;   // Base color tint
                float4 _SpecColor;   // Specular highlight color
                float  _Shininess;   // Sharpness of specular reflection
                float _mySlider;     // Strength of bump/normal effect
                float4 _myBump_ST;   // Tiling and offset for bump map
                float  _RimPower;    // Controls rim falloff
                float _RimIntensity; // Controls brightness of rim light

                // Lighting toggles (0 = off, 1 = on)
                float _UseDiffuse;
                float _UseAmbient;
                float _UseSpecular;
                float _UseBhong;
                float _UseRim;
            CBUFFER_END

            //  Vertex Shader
            Varyings vert (Attributes IN)
            {
                Varyings OUT;

                // Convert vertex position to clip space for rasterization
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);

                // Convert normal and tangent to world space and normalize
                OUT.normalWS = normalize(TransformObjectToWorldNormal(IN.normalOS));
                OUT.tangentWS = normalize(TransformObjectToWorldNormal(IN.tangentOS.xyz));

                // Bitangent is calculated using cross product and tangent.w sign
                OUT.bitangentWS = cross(OUT.normalWS, OUT.tangentWS) * IN.tangentOS.w;

                // Calculate direction from vertex to camera
                float3 worldPosWS = TransformObjectToWorld(IN.positionOS.xyz);
                OUT.viewDirWS = normalize(GetCameraPositionWS() - worldPosWS);

                // Pass UVs for texture sampling
                OUT.uv = IN.uv;
                return OUT;
            }


            //  Fragment Shader
            half4 frag (Varyings IN) : SV_Target
            {
                // --- Step 1: Sample the base texture and apply color tint ---
                half4 texColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv);
                half3 base = texColor.rgb * _BaseColor.rgb; // combines texture + color

                half3 normalWS;
                // If Phong/Bump is enabled, use normal map
                if (_UseBhong > 0.5)
                {
                    // Apply tiling and offset to UVs
                    float2 bumpUV = IN.uv * _myBump_ST.xy + _myBump_ST.zw;

                    // Unpack normal from bump texture (stored as RGB)
                    half3 normalTS = UnpackNormal(SAMPLE_TEXTURE2D(_myBump, sampler_myBump, bumpUV));

                    // Scale bump intensity using slider
                    normalTS.xy *= _mySlider;

                    // Build TBN matrix to convert tangent-space normal to world space
                    half3x3 TBN = half3x3(IN.tangentWS, IN.bitangentWS, IN.normalWS);
                    normalWS = normalize(mul(normalTS, TBN)); // transform to world space
                }
                else
                {
                    // If bump not used, just use the vertex normal
                    normalWS = normalize(IN.normalWS);
                }

                Light mainLight = GetMainLight(); // Gets URP's main directional light
                half3 lightDir = normalize(mainLight.direction);
               
                // N·L term for Lambert’s cosine law; clamp negative values
                half NdotL = saturate(dot(normalWS, lightDir));

                // Diffuse: light scattered evenly depending on N·L
                half3 diffuse = base * NdotL;

                // Ambient: environment light using Spherical Harmonics (approx global light)
                half3 ambient = SampleSH(normalWS) * base;

                // Fetch the same for debug or extra blending if needed
                half3 ambientSH = SampleSH(normalWS);

                // Specular: reflection intensity depending on viewing angle
                half3 reflectDir = reflect(-lightDir, normalWS); // reflection vector
                half3 viewDir = normalize(IN.viewDirWS);
                half specFactor = pow(saturate(dot(reflectDir, viewDir)), _Shininess);
                half3 specular = _SpecColor.rgb * specFactor;

                // Rim lighting: highlights edges facing away from light/view
                half rimFactor = 1.0 - saturate(dot(viewDir, normalize(IN.normalWS)));
                half rimLighting = pow(rimFactor, _RimPower);
                half3 rimColor = _SpecColor.rgb * rimLighting * _RimIntensity;

                // Initialize final color as black
                half3 finalColor = 0;

                // Add each component if its toggle is enabled
                if (_UseDiffuse > 0.5) finalColor += diffuse;   // Adds diffuse if enabled
                if (_UseAmbient > 0.5) finalColor += ambient;   // Adds ambient light
                if (_UseSpecular > 0.5) finalColor += specular; // Adds specular highlight
                if (_UseRim > 0.5) finalColor += rimColor;      // Adds rim effect
                
                // --- Step 5: Return final color ---
                return half4(finalColor, 1.0); // final RGB + full opacity
            }

            ENDHLSL
        }
    }
}

