using UnityEngine;
using UnityEngine.AI;

public class Vector9Movement : MonoBehaviour
{
    [SerializeField] private Transform playerPosition;
    [SerializeField] private Transform spawnLocation;

    private NavMeshAgent agent;

    private void Awake()
    {
        agent = GetComponent<NavMeshAgent>();
    }

    private void OnTriggerStay(Collider other)
    {
        if (other.CompareTag("Player"))
        {
            agent.destination = playerPosition.position;
        }
    }

    private void OnTriggerExit(Collider other)
    {
        if (other.CompareTag("Player"))
        {
            agent.destination = spawnLocation.position;
        }
    }

}
