using UnityEngine;

public class KeyCard : MonoBehaviour
{
    public GameObject inticon, keycard, playerCursor;

    private void OnTriggerStay(Collider other)
    {
        if (other.CompareTag("MainCamera"))
        {
            inticon.SetActive(true);
            playerCursor.SetActive(false);
            if (Input.GetKeyDown(KeyCode.E))
            {
                keycard.SetActive(false);
                inticon.SetActive(false);
                Door.keyFound = true;
                playerCursor.SetActive(true);
            }
        }
    }

    private void OnTriggerExit(Collider other)
    {
        if (other.CompareTag("MainCamera"))
        {
            inticon.SetActive(false);
            playerCursor.SetActive(true);
        }
    }
}
