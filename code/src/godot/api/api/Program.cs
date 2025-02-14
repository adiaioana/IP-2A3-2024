﻿using System;
using System.Text;
using System.Threading.Tasks;
using System.Net;
using System.Net.Sockets;


public class playerData
{
    public string faction { get; set; }
    public int spice { get; set; }
    public string[] treacheryCards { get; set; }

    public int newStormPosition { get; set; }
    public bool phase1NeedInput { get; set; } = true;
    public int cursedTimer { get; set; }
    public int round { get; set; }
    public int phase { get; set; } = 1;
}

public class Program
{
    public static async Task Main(string[] args)
    {
        await new GameClient("andy", "coolpassword").Run(args);
    }
}

public class GameClient
{
    //  for testing
    public playerData playerData1 = new playerData();
    public int playerID; /* 1 -> 6 */
    public string authToken; /* playerX */
  
    static readonly HttpClient client = new HttpClient();
    static string baseUrl = "http://localhost:1234/";
    private string username { get; set; }
    private string password { get; set; }


    public async Task Run(string[] args)
    {
        // Authentication
        authToken = await AuthenticateUser(username, password);
        Console.WriteLine($"Auth Token: {authToken}");

        playerID = GetPlayerID();

        // Get Gamestate for a specific player
        string gamestate = await GetGamestate(authToken);
        Console.WriteLine($"Gamestate for {authToken}: {gamestate}");
        string game = await InitializeGamestate(authToken, gamestate);
        Console.WriteLine(game);

        // Deserialize the JSON string into a JObject
        dynamic jsonObject = Newtonsoft.Json.JsonConvert.DeserializeObject(gamestate);


        //////////////////////////////////////////////////////////////////////////////////////////
        // COMMUNICATION WITH GUI ////////////////////////////////////////////////////////////////////
        playerData1.faction = jsonObject.Faction[0];
        playerData1.spice = jsonObject.Faction_Knowledge[0].Spice;
        // treatchery cards
        // Initialize a string array to hold the keys from the Treachery_Cards object
        // Fill the array with keys from the Treachery_Cards object
        int index = 0;
        foreach (var property in jsonObject.Faction_Knowledge[0].Treatchery_Cards.Properties())
        {
            playerData1.treacheryCards[index] = property.Name;
            index++;
        }
        // getting stuff from the jsonObject
        Console.WriteLine($"Faction: {jsonObject.Faction[0]}");
        playerData1.newStormPosition = -1;
        playerData1.cursedTimer = -1;
        playerData1.round = 1;
        
        ////
        
        HttpListener listener = new HttpListener();
        listener.Prefixes.Add("http://localhost:1236/");
        listener.Start();
        Console.WriteLine("Listening...");

        while (true)
        {
            HttpListenerContext context = listener.GetContext();
            HttpListenerRequest request = context.Request;
            HttpListenerResponse response = context.Response;

            string responseString = ProcessRequest(request.RawUrl);
            byte[] buffer = Encoding.UTF8.GetBytes(responseString);
            Console.WriteLine("{0} request received for {1}", request.HttpMethod, request.RawUrl);


            response.ContentType = "application/json"; // Set content type to JSON
            response.ContentLength64 = buffer.Length;
            response.OutputStream.Write(buffer, 0, buffer.Length);
            response.OutputStream.Close();
        }
    }

    public GameClient()
    {
        InitializeDefaultCredentials();
    }
    public GameClient(string theUsername, string thePassword)
    {
        this.username = theUsername;
        this.password = thePassword;
    }

    private void InitializeDefaultCredentials()
    {
        username = "girlboss";
        password = "password1";
    }

    int GetPlayerID()
    {
        int playerID = 0;
        if (int.TryParse(authToken.Substring(6), out playerID))
        {
            Console.WriteLine("Player ID: " + playerID);
        }
        else
        {
            Console.WriteLine("Failed to extract player ID.");
        }
        return playerID;
    }

    public async Task SendPlayerAction(string action, int playerID)
    {
        string endpoint = "/playeraction/" + "player" + playerID.ToString();
        var content = new StringContent(action);
        HttpResponseMessage response = await client.PostAsync(baseUrl + endpoint, content);
        response.EnsureSuccessStatusCode();
    }

    public async Task<string> AuthenticateUser(string username, string password)
    {
        var requestBody = new StringContent($"{username}:{password}", Encoding.UTF8, "application/x-www-form-urlencoded");
        var response = await client.PostAsync(baseUrl + "auth", requestBody);
        return await response.Content.ReadAsStringAsync();
    }

    public async Task<string> GetGamestate(string theAuthToken)
    {
        client.DefaultRequestHeaders.Remove("Authorization");
        client.DefaultRequestHeaders.Add("Authorization", theAuthToken);
        var response = await client.GetAsync(baseUrl + $"gamestate/{theAuthToken}");
        return await response.Content.ReadAsStringAsync();
    }

    public async Task<string> InitializeGamestate(string theAuthToken, string gamestate)
    {
        client.DefaultRequestHeaders.Remove("Authorization");
        client.DefaultRequestHeaders.Add("Authorization", theAuthToken);
        var requestBody = new StringContent(gamestate, Encoding.UTF8, "application/json");
        var response = await client.PostAsync(baseUrl + "initialization", requestBody);
        return await response.Content.ReadAsStringAsync();
    }
    public async Task<string> PostMoveForPlayer(string theAuthToken, string move)
        {
        client.DefaultRequestHeaders.Remove("Authorization");
        client.DefaultRequestHeaders.Add("Authorization", theAuthToken);
        var requestBody = new StringContent(move, Encoding.UTF8, "application/json");
        var response = await client.PostAsync(baseUrl + $"/validatemove/{theAuthToken}", requestBody);
        return await response.Content.ReadAsStringAsync();
    }

    public async Task<string> GetCharittyInfo()
    {
        var response = await client.GetAsync(baseUrl+"/phase_3_info");
        return await response.Content.ReadAsStringAsync();
    }

    // STUFF FOR COMMUNICATION WITH API ////////////////////////////////////////

    public string ProcessRequest(string request)
    {
        // Parse request and call appropriate API function
        if (request.StartsWith("/get_player_data"))
        {
            return GetPlayerData();
        }
        if (request.StartsWith("/login"))
        {
            string username = request.Split('/')[2];
            string password = request.Split('/')[3];
            return Login(username, password);
        }
        else if (request.StartsWith("/connect"))
        {
            return CheckConnection();
        }
        else if (request.StartsWith("/get_other_players_data"))
        {
            return GetOtherPlayersData();
        }
        else if (request.StartsWith("/get_map_spice"))
        {
            return GetMapSpice();
        }
        else if (request.StartsWith("/get_phase_info"))
        {
            return GetPhaseInfo();
        }
        else if (request.StartsWith("/get_phase_1_info"))
        {
            return GetPhase1Info();
        }
        else if (request.StartsWith("/phase_1_input"))
        {
            int stormValue = int.Parse(request.Split('/')[2]);
            return phase1Input(stormValue);
        }
        else if (request.StartsWith("/get_phase_2_info"))
        {
            return GetPhase2Info();
        }
        else if (request.StartsWith("/get_phase_3_info"))
        {
            return GetPhase3Info();
        }
        else
        {
            return "Invalid request";
        }
    }


    static string CheckConnection()
    {
        // Retrieve player data from the database or another source
        var playerData = new
        {
            message = "ok!"
        };

        // Serialize playerData object to JSON
        return Newtonsoft.Json.JsonConvert.SerializeObject(playerData);
    }
    static string Login(string username, string password)
    {
        Console.WriteLine("Trying to log in {0} with pass {1}", username, password);
        // Retrieve player data from the database or another source
        if (username == "andy" && password == "coolpassword")
        {
            var playerData = new
            {
                username = "andy"
            };
            // Serialize playerData object to JSON
            return Newtonsoft.Json.JsonConvert.SerializeObject(playerData);
        }
        else
        {
            var playerData = new
            {
                username = "error"
            };
            // Serialize playerData object to JSON
            return Newtonsoft.Json.JsonConvert.SerializeObject(playerData);
        }


    }
    public string GetPlayerData()
    {
        // Retrieve player data from the database or another source

        var playerDat = new
        {
            turnId = 1,
            faction = playerData1.faction,
            spice = playerData1.spice,
            forcesReserve = 20,
            forcesDeployed = 0,
            forcesDead = 0,
            leaders = new[]
            {
                new { name = "Leader1", faction = "Atreides", power = 1, @protected = false, status = "alive" },
                new { name = "Leader2", faction = "Atreides", power = 2, @protected = false, status = "alive" },
                new { name = "Leader3", faction = "Atreides", power = 3, @protected = false, status = "alive" },
                new { name = "Leader4", faction = "Atreides", power = 4, @protected = false, status = "alive" },
                new { name = "Leader5", faction = "Atreides", power = 5, @protected = false, status = "alive" }
            },
            territories = new object[0],
            traitors = new object[0],
            treacheryCards = new object[0]
        };
        // Serialize playerData object to JSON
        return Newtonsoft.Json.JsonConvert.SerializeObject(playerDat);
    }
    public string GetOtherPlayersData()
    {
        // Retrieve player data from the database or another source
        // MAKE SURE TURN ID'S ARE IN ORDER ASCENDING !!!
        var otherPlayers = new[]
        {
            new { turnId = 2, username = "SomeDude", faction = "harkonnen", bot = "no", spice = "5" },
            new { turnId = 3, username = "Luffy", faction = "space_guild", bot = "no", spice = "5"  },
            new { turnId = 4, username = "Bahhhh", faction = "bene_gesserit", bot = "no", spice = "5"  },
            new { turnId = 5, username = "Noob420", faction = "emperor", bot = "no", spice = "5"  },
            new { turnId = 6, username = "Bot1", faction = "fremen", bot = "yes", spice = "5"  }
        };

        // Serialize playerData object to JSON
        return Newtonsoft.Json.JsonConvert.SerializeObject(otherPlayers);
    }
    public string GetPhaseInfo()
    {
        var phaseInfo = new
        {
            round = playerData1.round,
            phase = playerData1.phase
        };

        // Serialize playerData object to JSON
        return Newtonsoft.Json.JsonConvert.SerializeObject(phaseInfo);
    }
    public string GetMapSpice()
    {
        var mapSpice = new[]
        {
            new { sector = "meridian", spice = "5" },
            new { sector = "cielago-depression", spice = "3" }
        };

        // Serialize playerData object to JSON
        return Newtonsoft.Json.JsonConvert.SerializeObject(mapSpice);
    }
    public string GetPhase1Info()
    {
        var phase1Info = new
        {
            whichPlayers = new[]
            {
                new { turnId = 2, hasPickedValue = "false" },
                new { turnId = 1, hasPickedValue = "false" }
            },
            newStormPosition = playerData1.newStormPosition
        };

        if (playerData1.newStormPosition == -1  && playerData1.cursedTimer < 10)
        {
            playerData1.cursedTimer++;
        }
        else if (playerData1.newStormPosition == -1 && playerData1.phase1NeedInput == false)
        {   playerData1.newStormPosition = 4; playerData1.cursedTimer = 0; playerData1.phase = 2; }
        // Serialize playerData object to JSON
        return Newtonsoft.Json.JsonConvert.SerializeObject(phase1Info);
    }
    public string phase1Input(int stormValue)
    {
        // send stormValue to server

        // response
        var validation = new
        {
            response = "ok"
        };
        playerData1.phase1NeedInput = false;
        playerData1.cursedTimer = 0;
        // Serialize playerData object to JSON
        return Newtonsoft.Json.JsonConvert.SerializeObject(validation);
    }
    public string GetPhase2Info()
    {
        var phase2Info = new
        {
            howMany  = 2,
            whichTerritories = new[]
            {
                new { name = "funeral-plain", addedSpice = 1 },
                new { name = "the-great-flat", addedSpice = 2 }
            },
        };

        if (playerData1.cursedTimer < 20)
        {
            playerData1.cursedTimer++;
        }
        else
        {   
            playerData1.phase = 3;
            Console.WriteLine("to phase 3 -----------------------");
            playerData1.cursedTimer = 0;
        }
        // Serialize playerData object to JSON
        return Newtonsoft.Json.JsonConvert.SerializeObject(phase2Info);
    }
    public string GetPhase3Info()
    {
        var phase2Info = new
        {
            howMany  = 2,
            whichPlayers = new[]
            {
                new { turnId = 1, addedSpice = 1 },
                new { turnId = 3, addedSpice = 2 }
            },
        };

        if (playerData1.cursedTimer < 20)
        {
            playerData1.cursedTimer++;
        }
        else
        {   
            playerData1.phase = 4;
            Console.WriteLine("to phase 4 -----------------------");
        }
        // Serialize playerData object to JSON
        return Newtonsoft.Json.JsonConvert.SerializeObject(phase2Info);
    }
}





