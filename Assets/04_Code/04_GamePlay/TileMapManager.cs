using System.Collections;
using System.Collections.Generic;
using UnityEngine.Tilemaps;
using UnityEngine;

public class TileMapManager : MonobehaviourSingleton<TileMapManager>
{
    [SerializeField] private Tilemap _TileMap;

    public Tilemap GetTileMap() => (_TileMap);
}
