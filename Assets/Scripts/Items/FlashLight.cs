using UnityEngine;

public class FlashLight : MonoBehaviour
{
    public GameObject flashlight_ground, inticon, flashlight_player,playerCursor;

    
    private void OnTriggerStay(Collider other)
    {
        if (other.CompareTag("MainCamera"))
        {
            inticon.SetActive(true);
            playerCursor.SetActive(false);
            if (Input.GetKeyDown(KeyCode.E))
            {
                flashlight_ground.SetActive(false);
                inticon.SetActive(false);
                playerCursor.SetActive(true);
                flashlight_player.SetActive(true);
            }
        }
    }

    private void OnTriggerExit(Collider other)
    {
        if (other.CompareTag("Player"))
        {
            inticon.SetActive(false);
            playerCursor.SetActive(true);
        }
    }
}
