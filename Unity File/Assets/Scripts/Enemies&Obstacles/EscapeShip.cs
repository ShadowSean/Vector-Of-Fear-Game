using UnityEngine;
using UnityEngine.SceneManagement;

public class EscapeShip : MonoBehaviour
{
    public string sceneName;
    public GameObject escapeMessage;
    public GameObject playerHealthStamina;
    public GameObject playerInventory;
    private FPController cameraRotation;
    private void OnTriggerEnter(Collider other)
    {
        cameraRotation = other.GetComponent<FPController>();
        if (cameraRotation != null)
        {
            cameraRotation.lookXLimit = 0;
            cameraRotation.LookSpeed = 0;
        }
        Cursor.lockState = CursorLockMode.None;
        Cursor.visible = true;
        playerHealthStamina.SetActive(false);
        playerInventory.SetActive(false);
        escapeMessage.SetActive(true);
    }
}
