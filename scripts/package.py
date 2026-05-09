import zipfile
import os
import shutil

def create_lambda_package():
    # Caminhos
    src_dir = 'src/lambda_functions'
    libs_dir = 'src/lambda_functions/libs'
    output_zip = 'infrastructure/lambda_function.zip'
    
    # Cria uma pasta temporária para montar o pacote
    temp_dir = 'temp_package'
    if os.path.exists(temp_dir): shutil.rmtree(temp_dir)
    os.makedirs(temp_dir)

    # 1. Copia o código da lambda
    shutil.copy(os.path.join(src_dir, 'processor.py'), os.path.join(temp_dir, 'processor.py'))

    # 2. Copia as dependências (conteúdo de libs) para a raiz do temp_dir
    if os.path.exists(libs_dir):
        for item in os.listdir(libs_dir):
            s = os.path.join(libs_dir, item)
            d = os.path.join(temp_dir, item)
            if os.path.isdir(s): shutil.copytree(s, d)
            else: shutil.copy2(s, d)

    # 3. Gera o ZIP a partir do temp_dir
    with zipfile.ZipFile(output_zip, 'w', zipfile.ZIP_DEFLATED) as zipf:
        for root, dirs, files in os.walk(temp_dir):
            for file in files:
                zipf.write(os.path.join(root, file), os.path.relpath(os.path.join(root, file), temp_dir))
    
    shutil.rmtree(temp_dir)
    print(f"Sucesso: {output_zip} reconstruído com dependências na raiz!")

if __name__ == "__main__":
    create_lambda_package()