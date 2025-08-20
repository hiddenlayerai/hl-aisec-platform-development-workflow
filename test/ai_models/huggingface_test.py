from transformers import AutoModel, AutoTokenizer, pipeline

# Direct model loading
model = AutoModel.from_pretrained("bert-base-uncased")
tokenizer = AutoTokenizer.from_pretrained("bert-base-uncased")

# Community models
stable_diffusion = pipeline("text-generation", model="gpt2") 

