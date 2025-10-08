using UnityEngine;
using System.Collections.Generic;
using System.Collections;
using UnityEngine.UIElements;

public class Door : MonoBehaviour
{
    //public AudioSource open,close;
    public static bool keyFound;
    public GameObject door_closed, door_opened, intText,playerScope, cardlockedtext;

    //public AudioSource open, close;

    public bool opened, locked;
    private void Start()
    {
        keyFound = false;
    }
    private void OnTriggerStay(Collider other)
    {
        if (other.CompareTag("MainCamera"))
        {
            if (opened == false)
            {
                if (locked == false)
                {
                    playerScope.SetActive(false);
                    intText.SetActive(true);
                    if (Input.GetKeyDown(KeyCode.E))
                    {
                        door_closed.SetActive(false);
                        door_opened.SetActive(true);
                        intText.SetActive(false);
                        playerScope.SetActive(true);
                        //open.Play();
                        StartCoroutine(repeat());
                        opened = true;
                    }
                }
                if (locked == true)
                {
                    cardlockedtext.SetActive(true);
                    playerScope.SetActive(false);
                }
            }
        }
    }

    private void OnTriggerExit(Collider other)
    {
        if (other.CompareTag("MainCamera"))
        {
            intText.SetActive(false);
            cardlockedtext.SetActive(false);
            playerScope.SetActive(true);
        }
    }

    IEnumerator repeat()
    {
        yield return new WaitForSeconds(4.0f);
        opened = false;
        door_closed.SetActive(true);
        door_opened.SetActive(false);
        //close.Play();
    }

    private void Update()
    {
        if (keyFound == true)
        {
            locked = false;
        }
    }
}
