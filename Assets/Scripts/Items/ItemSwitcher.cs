using UnityEngine;

public class ItemSwitcher : MonoBehaviour
{
    public GameObject flashlight_player;
    public GameObject taserRod_player;

    public GameObject flashlightIcon;
    public GameObject taserIcon;

    private int currentItemIndex = 0;
    private bool hasFlashlight = false;
    private bool hasTaser = false;

    private void Update()
    {
        if (Input.GetKeyDown(KeyCode.Alpha1) && hasFlashlight)
        {
            EquipItem(1);
        }

        if (Input.GetKeyDown(KeyCode.Alpha2) && hasTaser)
        {
            EquipItem(2);
        }
    }

    void EquipItem(int index)
    {
        currentItemIndex = index;

        flashlight_player.SetActive(index == 1);
        taserRod_player.SetActive(index == 2);

        UpdateIcons();
    }

    void CycleItems(int direction)
    {
        int maxItems = (hasFlashlight ? 1 : 0) + (hasTaser ? 1 : 0);
        if (maxItems <= 1) return;

        int[] availableItems = new int[maxItems];
        int count = 0;
        if (hasFlashlight) availableItems[count++] = 1;
        if(hasTaser) availableItems[count++] = 2;
        
        int currentIndex = System.Array.IndexOf(availableItems, currentItemIndex);
        currentIndex = (currentIndex + direction + count) % count;
        EquipItem(availableItems[currentIndex]);
    }

    public void PickupFlashlight()
    {
        hasFlashlight = true;
        UpdateIcons();
        EquipItem(1);
    }

    public void PickupTaser()
    {
        hasTaser = true;
        UpdateIcons();
        EquipItem(2);
    }

    void UpdateIcons()
    {
        if (flashlightIcon != null)
        {
            flashlightIcon.SetActive(hasFlashlight);
        }

        if (taserIcon != null)
        {
            taserIcon.SetActive(hasTaser);
        }
    }
}
