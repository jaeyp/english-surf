import json
import uuid
from datetime import datetime

file_path = 'assets/data/spanish_travel.json'

try:
    with open(file_path, 'r', encoding='utf-8') as f:
        data = json.load(f)
except Exception as e:
    print(f"Error reading file: {e}")
    exit(1)

# Extract simple sentences if present
simple_sentences = data.get('sentences', [])

folder_id = str(uuid.uuid4())
created_at = datetime.now().isoformat()

new_data = {
    "folder": {
        "id": folder_id,
        "name": "🇪🇸 기초 여행 스페인어",
        "created_at": created_at,
        "flag_color": "0xFFFFEB3B",
        "original_language": "es",
        "translation_language": "ko"
    },
    "sentences": []
}

for i, s in enumerate(simple_sentences):
    # Handle simple string input from my previous generation
    orig_input = s.get('original', '')
    orig_text = orig_input
    if isinstance(orig_input, dict):
        orig_text = orig_input.get('text', '')
    
    trans_text = s.get('translation', '')

    new_s = {
        "id": i,
        "order": i,
        "original": {
            "text": orig_text,
            "styles": []
        },
        "translation": trans_text,
        "difficulty": "beginner",
        "paraphrases": [],
        "notes": "",
        "is_favorite": False
    }
    new_data['sentences'].append(new_s)

with open(file_path, 'w', encoding='utf-8') as f:
    json.dump(new_data, f, ensure_ascii=False, indent=2)

print(f"Fixed {file_path} with {len(new_data['sentences'])} sentences.")
