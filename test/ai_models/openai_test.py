from openai import OpenAI

client = OpenAI(api_key="test-key")

# GPT-4 usage
response = client.chat.completions.create(
    model="gpt-4",
    messages=[
        {"role": "system", "content": "You are a helpful assistant."},
        {"role": "user", "content": "Hello!"}
    ]
)

# GPT-3.5 usage
response = client.chat.completions.create(
    model="gpt-3.5-turbo",
    messages=[{"role": "user", "content": "Test message"}]
) 