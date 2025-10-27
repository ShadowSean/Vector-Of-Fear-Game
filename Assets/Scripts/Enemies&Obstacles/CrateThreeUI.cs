using UnityEngine;

public class CrateThreeUI : MonoBehaviour
{
    public GameObject crateui, equipIcon, playerCursor, equippedIcon;

    public static bool partsCollectedThree;

    bool inRange;
    bool itemEquipped;

    private FPController cameraMovement;

    private void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag("Player"))
        {
            cameraMovement = other.GetComponent<FPController>();
            if (cameraMovement != null)
            {
                cameraMovement.lookXLimit = 0;
                cameraMovement.LookSpeed = 0;
            }
            inRange = true;
            playerCursor.SetActive(false);
            crateui.SetActive(true);
            equipIcon.SetActive(true);
            equippedIcon.SetActive(false);
            Cursor.lockState = CursorLockMode.None;
            Cursor.visible = true;
        }
    }

    private void OnTriggerStay(Collider other)
    {
        if (inRange && other.CompareTag("Player"))
        {
            if (Input.GetMouseButtonDown(0) && !itemEquipped)
            {
                equipIcon.SetActive(false);
                equippedIcon.SetActive(true);
                itemEquipped = true;
                partsCollectedThree = true;
            }
        }
    }

    private void OnTriggerExit(Collider other)
    {
        if (other.CompareTag("Player"))
        {
            if (cameraMovement != null)
            {
                cameraMovement.lookXLimit = 45;
                cameraMovement.LookSpeed = 5;
            }
            inRange = false;
            crateui.SetActive(false);
            equipIcon.SetActive(false);
            equippedIcon.SetActive(false);
            playerCursor.SetActive(true);
            Cursor.lockState = CursorLockMode.Locked;
            Cursor.visible = false;
        }
    }
}
