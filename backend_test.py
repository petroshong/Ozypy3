
import requests
import sys
import json
from datetime import datetime

class ETLServiceTester:
    def __init__(self, base_url="https://195f5608-b84a-426b-9bd9-62be96832f92.preview.emergentagent.com"):
        self.base_url = base_url
        self.api_url = f"{base_url}/api"
        self.tests_run = 0
        self.tests_passed = 0

    def run_test(self, name, method, endpoint, expected_status, data=None):
        """Run a single API test"""
        url = f"{self.api_url}/{endpoint}"
        headers = {'Content-Type': 'application/json'}
        
        self.tests_run += 1
        print(f"\n🔍 Testing {name}...")
        
        try:
            if method == 'GET':
                response = requests.get(url, headers=headers)
            elif method == 'POST':
                response = requests.post(url, json=data, headers=headers)
            elif method == 'DELETE':
                response = requests.delete(url, headers=headers)
            
            success = response.status_code == expected_status
            if success:
                self.tests_passed += 1
                print(f"✅ Passed - Status: {response.status_code}")
                if response.status_code != 204:  # No content
                    try:
                        return success, response.json()
                    except json.JSONDecodeError:
                        return success, {"message": "No JSON content"}
                return success, {}
            else:
                print(f"❌ Failed - Expected {expected_status}, got {response.status_code}")
                try:
                    error_content = response.json()
                    print(f"Error response: {error_content}")
                except:
                    print(f"Error response: {response.text}")
                return False, {}

        except Exception as e:
            print(f"❌ Failed - Error: {str(e)}")
            return False, {}

    def test_welcome_message(self):
        """Test the welcome message endpoint"""
        return self.run_test(
            "Welcome Message",
            "GET",
            "",
            200
        )

    def test_list_sources(self):
        """Test listing all sources"""
        return self.run_test(
            "List Sources",
            "GET",
            "sources",
            200
        )
    
    def test_list_transformations(self):
        """Test listing all transformations"""
        return self.run_test(
            "List Transformations",
            "GET",
            "transformations",
            200
        )
    
    def test_list_destinations(self):
        """Test listing all destinations"""
        return self.run_test(
            "List Destinations",
            "GET",
            "destinations",
            200
        )
    
    def test_list_pipelines(self):
        """Test listing all pipelines"""
        return self.run_test(
            "List Pipelines",
            "GET",
            "pipelines",
            200
        )
    
    def test_create_source(self):
        """Test creating a new data source"""
        source_data = {
            "name": f"Test PostgreSQL Source {datetime.now().strftime('%H%M%S')}",
            "type": "postgres",
            "credentials": {
                "host": "localhost",
                "port": 5432,
                "username": "test_user",
                "password": "test_password",
                "database": "test_db"
            }
        }
        return self.run_test(
            "Create Source",
            "POST",
            "sources",
            201,
            data=source_data
        )
    
    def test_create_transformation(self):
        """Test creating a new transformation rule"""
        transformation_data = {
            "name": f"Test Transformation {datetime.now().strftime('%H%M%S')}",
            "type": "natural_language",
            "definition": "Convert all names to uppercase format"
        }
        return self.run_test(
            "Create Transformation",
            "POST",
            "transformations",
            201,
            data=transformation_data
        )
    
    def test_create_destination(self):
        """Test creating a new destination"""
        destination_data = {
            "name": f"Test Destination {datetime.now().strftime('%H%M%S')}",
            "type": "json",
            "configuration": {
                "path": "/tmp/output.json",
                "format": "pretty"
            }
        }
        return self.run_test(
            "Create Destination",
            "POST",
            "destinations",
            201,
            data=destination_data
        )
    
    def test_natural_language_transform(self):
        """Test the natural language transformation endpoint"""
        test_data = {
            "input_data": {
                "users": [
                    {"name": "John Doe", "email": "john@example.com"},
                    {"name": "Jane Smith", "email": "jane@example.com"}
                ]
            },
            "instruction": "Convert all names to uppercase format"
        }
        return self.run_test(
            "Natural Language Transform",
            "POST",
            "transformations/test/natural_language",
            200,
            data=test_data
        )

    def test_agent_help_command(self):
        """Test the AI agent help command"""
        command_data = {
            "command": "help"
        }
        return self.run_test(
            "AI Agent Help Command",
            "POST",
            "agent/command",
            200,
            data=command_data
        )
    
    def test_agent_list_pipelines_command(self):
        """Test the AI agent list pipelines command"""
        command_data = {
            "command": "list pipelines"
        }
        return self.run_test(
            "AI Agent List Pipelines Command",
            "POST",
            "agent/command",
            200,
            data=command_data
        )
    
    def test_agent_run_pipeline_command(self, pipeline_id):
        """Test the AI agent run pipeline command"""
        command_data = {
            "command": "run pipeline",
            "pipeline_id": pipeline_id
        }
        return self.run_test(
            "AI Agent Run Pipeline Command",
            "POST",
            "agent/command",
            200,
            data=command_data
        )
    
    def test_agent_status_command(self, pipeline_id=None):
        """Test the AI agent status command"""
        command_data = {
            "command": "status"
        }
        if pipeline_id:
            command_data["pipeline_id"] = pipeline_id
            
        return self.run_test(
            "AI Agent Status Command",
            "POST",
            "agent/command",
            200,
            data=command_data
        )

def main():
    # Setup
    tester = ETLServiceTester()
    
    # Run tests
    print("\n===== Testing ETL Service API =====\n")
    
    # Test welcome message
    tester.test_welcome_message()
    
    # Test listing endpoints
    tester.test_list_sources()
    tester.test_list_transformations()
    tester.test_list_destinations()
    success, pipelines_response = tester.test_list_pipelines()
    
    # Test creation endpoints
    tester.test_create_source()
    tester.test_create_transformation()
    tester.test_create_destination()
    
    # Test transformation functionality
    success, response = tester.test_natural_language_transform()
    if success:
        print("Transformation result:")
        print(json.dumps(response, indent=2))
    
    # Test AI Agent endpoints
    print("\n===== Testing AI Agent API =====\n")
    
    # Test help command
    success, help_response = tester.test_agent_help_command()
    if success:
        print("AI Agent Help Response:")
        print(json.dumps(help_response, indent=2))
    
    # Test list pipelines command
    success, list_pipelines_response = tester.test_agent_list_pipelines_command()
    if success:
        print("AI Agent List Pipelines Response:")
        print(json.dumps(list_pipelines_response, indent=2))
    
    # Test status command (system status)
    success, status_response = tester.test_agent_status_command()
    if success:
        print("AI Agent Status Response:")
        print(json.dumps(status_response, indent=2))
    
    # Test run pipeline and pipeline status commands if pipelines exist
    if success and pipelines_response and "pipelines" in list_pipelines_response.get("data", {}):
        pipelines = list_pipelines_response["data"]["pipelines"]
        if pipelines:
            pipeline_id = pipelines[0]["id"]
            
            # Test run pipeline command
            success, run_response = tester.test_agent_run_pipeline_command(pipeline_id)
            if success:
                print(f"AI Agent Run Pipeline Response (Pipeline ID: {pipeline_id}):")
                print(json.dumps(run_response, indent=2))
            
            # Test pipeline status command
            success, pipeline_status_response = tester.test_agent_status_command(pipeline_id)
            if success:
                print(f"AI Agent Pipeline Status Response (Pipeline ID: {pipeline_id}):")
                print(json.dumps(pipeline_status_response, indent=2))
    
    # Print results
    print(f"\n📊 Tests passed: {tester.tests_passed}/{tester.tests_run}")
    return 0 if tester.tests_passed == tester.tests_run else 1

if __name__ == "__main__":
    sys.exit(main())
