import asyncio
from fastapi import FastAPI, Request
from langchain_ollama import ChatOllama

from contextlib import asynccontextmanager
from langchain.agents import create_agent 
from langchain_mcp_adapters.client import MultiServerMCPClient
import uvicorn


# Configuration

#OLLAMA_BASE_URL = "http://localhost:11434"
#MCP_SERVER_URL = "http://localhost:8888/mcp"
#MODEL = "qwen3:8b" 
OLLAMA_BASE_URL = "http://rpi5.local:11434"
MCP_SERVER_URL = "http://localhost:8888/mcp"
MODEL = "qwen2.5:3b" 

mcp_tools = []
mcp_client = None

@asynccontextmanager
async def lifespan(app: FastAPI):
    global mcp_tools, mcp_client
    
    # --- Startup Logic ---
    print("Initializing Agent & MCP Connection...")
    
    mcp_client = MultiServerMCPClient({
        "geo_service": {"url": MCP_SERVER_URL, "transport": "http"}
    })
    
    # Load tools once into memory
    mcp_tools = await mcp_client.get_tools()
    print(f"Loaded {len(mcp_tools)} tools from MCP.")
    
    yield  # The app runs here
    
    # --- Shutdown Logic ---
    print("Shutting down. Cleaning up MCP sessions...")
    # Add any specific cleanup if your version of mcp_client requires it


# Create FastAPI app with lifespan
app = FastAPI(lifespan=lifespan)

# Initialize the Chat Model
llm = ChatOllama(base_url=OLLAMA_BASE_URL, model=MODEL, temperature=0)

@app.post("/prompt")
async def handle_prompt(request: Request):
    data = await request.json()
    user_input = data.get("prompt")

    # Fetch available tools from MCP
    tools = await mcp_client.get_tools()
    
    # NEW: Use create_agent with 'system_prompt' parameter
    # This replaces the need for the manually structured ChatPromptTemplate
    agent_executor = create_agent(
        llm, 
        tools, 
        system_prompt="You are a Geolocation Agent. Use your tools to find coordinates, "
                      "calculate shortest paths, and generate drive-time polygons."
    )
    
    # Invoke using the modern 'messages' schema
    result = await agent_executor.ainvoke({"messages": [("user", user_input)]})
    
    # Return the content of the last AI message
    return {"output": result["messages"][-1].content}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)

