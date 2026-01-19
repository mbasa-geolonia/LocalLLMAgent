import asyncio
from fastapi import FastAPI, Request
from langchain_ollama import ChatOllama
from langgraph.prebuilt import create_react_agent
from langchain_mcp_adapters.client import MultiServerMCPClient
import uvicorn

app = FastAPI()

# Configuration
OLLAMA_BASE_URL = "http://localhost:11434"
MCP_SERVER_URL = "http://marionomac-mini.local/mcpLocation/mcp"
MODEL = "qwen3:8b"

# 1. Initialize the Chat Model
llm = ChatOllama(base_url=OLLAMA_BASE_URL, model=MODEL, temperature=0)

# 2. Initialize the MCP Client (Not as a context manager)
# We do this globally or per-request depending on your scaling needs
mcp_client = MultiServerMCPClient(
    {
        "geo_service": {
            "url": MCP_SERVER_URL,
            "transport": "http"
        }
    }
)

@app.post("/prompt")
async def handle_prompt(request: Request):
    data = await request.json()
    user_input = data.get("prompt")

    # Fetch tools from the MCP server
    tools = await mcp_client.get_tools()
    
    # Create the modern LangGraph React Agent
    # This replaces the old AgentExecutor and is much more robust
    agent_executor = create_react_agent(llm, tools)
    
    # Execute the agent
    # We pass the input as a list of messages
    inputs = {"messages": [("user", user_input)]}
    result = await agent_executor.ainvoke(inputs)
    
    # The last message in the list is the assistant's final response
    final_answer = result["messages"][-1].content
    
    return {"output": final_answer}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)

