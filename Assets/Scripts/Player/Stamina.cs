using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.UI;

public class Stamina : MonoBehaviour
{
    [Header("Stamina Settings")]
    public Slider staminaBar;
    public float maxStamina = 100f;
    public float staminaDrain = 10f;
    public float staminaRegen = 5f;


    [HideInInspector] public float currentStam;
    private FPController staminaMovement;

    private void Start()
    {
        staminaMovement = FindFirstObjectByType<FPController>();
        currentStam = maxStamina;

        if (staminaBar != null)
        {
            staminaBar.maxValue = maxStamina;
            staminaBar.value = maxStamina;
        }
        
    }

    private void Update()
    {
        if (staminaMovement == null) return;

        bool isRunning = Input.GetKey(KeyCode.LeftShift);
        bool isMoving = Input.GetAxis("Horizontal") !=0 || Input.GetAxis("Vertical") != 0;

        if (isRunning && isMoving && currentStam > 0)
        {
            currentStam -= staminaDrain * Time.deltaTime;
            if (currentStam < 0)
            {
                currentStam = 0;
            }
        }
        else
        {
            if (currentStam < maxStamina)
            {
                currentStam += staminaRegen * Time.deltaTime;
            }
        }
        if (staminaBar != null)
        {
            staminaBar.value = currentStam;
        }
        
    }

    public bool hasStamina()
    {
        return currentStam > 0;
    }
}
