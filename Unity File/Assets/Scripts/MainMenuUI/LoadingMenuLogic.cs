using System.Collections;
using UnityEngine;

public class LoadingMenuLogic : MonoBehaviour
{
    [Header("Screens")]
    public GameObject loadingScreen, clickScreen;

    [Header("Screen Duration")]
    public float displayDuration = 3f;

    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        StartCoroutine(SwitchScreens());  
    }

   IEnumerator SwitchScreens()
    {
        yield return new WaitForSeconds(displayDuration);

        if (loadingScreen != null)
        {
            loadingScreen.SetActive(false);
        }

        if (clickScreen != null)
        {
            clickScreen.SetActive(true);
        }
    }
}
