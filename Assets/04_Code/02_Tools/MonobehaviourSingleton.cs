using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MonobehaviourSingleton<T> : MonoBehaviour where T : MonoBehaviour
{
    [HideInInspector] public static T Inst;

    [SerializeField] private bool _DontDestroyOnLoad = false;

    public virtual void Awake()
    {
        if (_DontDestroyOnLoad)
        {
            if (Inst != null)
            {
                Destroy(this);
            }
            else
            {
                Inst = this as T;

                DontDestroyOnLoad(transform.root.gameObject);
            }
        }
        else
        {
            Debug.Assert(Inst == null, "Already existing instance of " + typeof(T).ToString());

            Inst = this as T;
        }
    }

    public virtual void OnDestroy()
    {
        Inst = null;
    }
}
