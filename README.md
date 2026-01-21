# LocalLLMAgent

Chat Agent that uses the Python LangChain library to test Ollama based Local LLMs. 

### Installation

* Create a Vitrual Environment (venv)
  ```shell
  python3 -m venv .venv
  ```

* Activate the Virtual Environment
  ```shell
  source .venv/bin/activate
  ```

* Install Required Libraries
  ```shell
  pip install -r requirements.txt
  ```

* Edit the `.env` file and place the correct values for the following parameters: 

  ```bash
  OLLAMA_BASE_URL=http://localhost:11434
  MCP_SERVER_URL=http://localhost:8888/mcp
  MODEL=qwen3:8b
  ```

* Run the Application
  ```shell
  python3 main.py
  ```

### Note
  If `Ollama`  and the `MCP Services` servers are installed in remotely such as in an AWS EC2 server,  
  and is only accessible via a SSH connection, it is possoble to create a secure tunnel first then this 
  application will be able to connect to the servers locally. 

  ```shell
  ssh -L11434:localhost:11434 -L8888:localhost:8888 user@EC2_Access_Address
  ```

### Using this Appliccation
  Once the application is running, `curl` can be used to send prompts into the Ollama LLM model. 

  ```shell
  curl -X POST http://localhost:8000/prompt -H "Content-Type: application/json" -d '{"prompt": "この住所 [東京都文京区 本駒込2-28-8] の半径500m圏内のPOIを取得してください。POIをカテゴリ別にリストアップしてください。"}'
  ```
  
### Benchnarking
  A benchmarking shell application, `benchmark.sh`, is included to test the responses of an Ollama model to defined 
  prompts as well as the model's correct usage of Model Context Protocol (MCP) Services tools. The PROMPTS can be
  edited to suit the desired test usages. A text file will be created to save the results of the LLM responses to 
  the sent prompts. 

  
