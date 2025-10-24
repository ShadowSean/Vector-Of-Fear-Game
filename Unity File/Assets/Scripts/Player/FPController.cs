using UnityEngine;


[RequireComponent(typeof(CharacterController))]

public class FPController : MonoBehaviour
{
    [Header("Movement")]
    public float walkingSpeed = 5.0f;
    public float runningSpeed = 10.0f;


    [Header("Camera")]
    public Camera playerCam;
    public float LookSpeed = 2.0f;
    public float lookXLimit = 45.0f;

    CharacterController controller;
    Vector3 moveDir = Vector3.zero;
    float rotationX = 0;


    [HideInInspector]
    public bool canMove = true;

    private Stamina stamina;

    private void Start()
    {
        controller = GetComponent<CharacterController>();
        stamina = FindFirstObjectByType<Stamina>();

        Cursor.lockState = CursorLockMode.Locked;
        Cursor.visible = false;
    }

    private void Update()
    {
        Vector3 forward = transform.TransformDirection(Vector3.forward);
        Vector3 right = transform.TransformDirection(Vector3.right);

        //When shift is pressed sprint
        bool hasStamina = stamina != null && stamina.hasStamina();
        bool isRunningKey = Input.GetKey(KeyCode.LeftShift) && hasStamina;
        
        float curSpeedX = canMove ? (isRunningKey ? runningSpeed : walkingSpeed) * Input.GetAxis("Vertical") : 0;
        float curSpeedY = canMove ? (isRunningKey ? runningSpeed : walkingSpeed) * Input.GetAxis("Horizontal") : 0;
        float movementDirectionY = moveDir.y;
        moveDir = (forward * curSpeedX) + (right * curSpeedY);

        controller.Move(moveDir * Time.deltaTime);

        if (canMove)
        {
            rotationX += -Input.GetAxis("Mouse Y") * LookSpeed;
            rotationX = Mathf.Clamp(rotationX, -lookXLimit, lookXLimit);
            playerCam.transform.localRotation = Quaternion.Euler(rotationX, 0, 0);
            transform.rotation *= Quaternion.Euler(0, Input.GetAxis("Mouse X") * LookSpeed, 0);
        }

    }

}
