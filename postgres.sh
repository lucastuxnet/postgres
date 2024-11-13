#!/bin/bash

# Configurações
BACKUP_DIR="/home/ubuntu/universe/postgres"
DATE=$(date +"%Y%m%d_%H%M%S")
DB_BACKUP_FILE="$BACKUP_DIR/postgresql_db_backup_$DATE.sql"
ROLE_BACKUP_FILE="$BACKUP_DIR/postgresql_roles_backup_$DATE.sql"
LOG_FILE="$BACKUP_DIR/backup_log_$DATE.log"

# Certifique-se de que o diretório de backup existe
mkdir -p "$BACKUP_DIR"

# Log de início
echo "[$(date +"%Y-%m-%d %H:%M:%S")] Iniciando processo de backup completo do PostgreSQL" | tee -a "$LOG_FILE"

# Listar todos os bancos de dados antes do backup
echo "[$(date +"%Y-%m-%d %H:%M:%S")] Listando todos os bancos de dados disponíveis..." | tee -a "$LOG_FILE"
DATABASES=$(sudo -u postgres psql -t -c "SELECT datname FROM pg_database WHERE datistemplate = false;")

if [ -z "$DATABASES" ]; then
    echo "[$(date +"%Y-%m-%d %H:%M:%S")] Nenhum banco de dados encontrado para backup." | tee -a "$LOG_FILE"
    exit 1
fi

# Listar os bancos de dados que serão salvos no log
echo "[$(date +"%Y-%m-%d %H:%M:%S")] Bancos de dados que serão salvos no backup:" | tee -a "$LOG_FILE"
for DB in $DATABASES; do
    echo "- $DB" | tee -a "$LOG_FILE"
done

# Confirmar antes de iniciar o backup
echo "[$(date +"%Y-%m-%d %H:%M:%S")] Iniciando backup dos bancos de dados listados..." | tee -a "$LOG_FILE"

# Backup de todos os bancos de dados (inclui estrutura e dados)
sudo -u postgres pg_dumpall -c > "$DB_BACKUP_FILE"

if [ $? -eq 0 ]; then
    echo "[$(date +"%Y-%m-%d %H:%M:%S")] Backup dos bancos de dados concluído com sucesso: $DB_BACKUP_FILE" | tee -a "$LOG_FILE"
else
    echo "[$(date +"%Y-%m-%d %H:%M:%S")] Erro ao realizar backup dos bancos de dados" | tee -a "$LOG_FILE"
    exit 1
fi

# Backup de todos os usuários (roles)
echo "[$(date +"%Y-%m-%d %H:%M:%S")] Iniciando backup dos usuários (roles)..." | tee -a "$LOG_FILE"
sudo -u postgres pg_dumpall -r > "$ROLE_BACKUP_FILE"

if [ $? -eq 0 ]; then
    echo "[$(date +"%Y-%m-%d %H:%M:%S")] Backup dos usuários concluído com sucesso: $ROLE_BACKUP_FILE" | tee -a "$LOG_FILE"
else
    echo "[$(date +"%Y-%m-%d %H:%M:%S")] Erro ao realizar backup dos usuários" | tee -a "$LOG_FILE"
    exit 1
fi

# Log de finalização
echo "[$(date +"%Y-%m-%d %H:%M:%S")] Backup completo do PostgreSQL finalizado com sucesso." | tee -a "$LOG_FILE"

# Limpeza de backups antigos (excluir backups com mais de 7 dias)
echo "[$(date +"%Y-%m-%d %H:%M:%S")] Iniciando limpeza de backups antigos..." | tee -a "$LOG_FILE"
find "$BACKUP_DIR" -type f -name "*.sql" -mtime +7 -exec rm {} \;
echo "[$(date +"%Y-%m-%d %H:%M:%S")] Limpeza de backups antigos concluída." | tee -a "$LOG_FILE"
