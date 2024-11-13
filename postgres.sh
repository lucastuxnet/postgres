#!/bin/bash

# Configurações
BACKUP_DIR="/home/esolvere/universe/backup"
DATE=$(date +"%Y%m%d_%H%M%S")
DB_BACKUP_FILE="$BACKUP_DIR/postgresql_db_backup_$DATE.sql"
ROLE_BACKUP_FILE="$BACKUP_DIR/postgresql_roles_backup_$DATE.sql"
LOG_FILE="$BACKUP_DIR/backup_log_$DATE.log"

# Log de início
echo "[$(date +"%Y-%m-%d %H:%M:%S")] Iniciando backup completo do PostgreSQL" | tee -a "$LOG_FILE"

# Backup de todos os bancos de dados (inclui estrutura e dados)
echo "[$(date +"%Y-%m-%d %H:%M:%S")] Backup dos bancos de dados em andamento..." | tee -a "$LOG_FILE"
sudo -u postgres pg_dumpall -c > "$DB_BACKUP_FILE"

if [ $? -eq 0 ]; then
    echo "[$(date +"%Y-%m-%d %H:%M:%S")] Backup dos bancos de dados concluído com sucesso: $DB_BACKUP_FILE" | tee -a "$LOG_FILE"
else
    echo "[$(date +"%Y-%m-%d %H:%M:%S")] Erro ao realizar backup dos bancos de dados" | tee -a "$LOG_FILE"
    exit 1
fi

# Backup de todos os usuários (roles)
echo "[$(date +"%Y-%m-%d %H:%M:%S")] Backup dos usuários (roles) em andamento..." | tee -a "$LOG_FILE"
sudo -u postgres pg_dumpall -r > "$ROLE_BACKUP_FILE"

if [ $? -eq 0 ]; then
    echo "[$(date +"%Y-%m-%d %H:%M:%S")] Backup dos usuários concluído com sucesso: $ROLE_BACKUP_FILE" | tee -a "$LOG_FILE"
else
    echo "[$(date +"%Y-%m-%d %H:%M:%S")] Erro ao realizar backup dos usuários" | tee -a "$LOG_FILE"
    exit 1
fi

# Log de finalização
echo "[$(date +"%Y-%m-%d %H:%M:%S")] Backup completo do PostgreSQL finalizado com sucesso." | tee -a "$LOG_FILE"

# Limpeza de backups antigos (excluir backups com mais de 15 dias)
find "$BACKUP_DIR" -type f -name "*.sql" -mtime +15 -exec rm {} \;
echo "[$(date +"%Y-%m-%d %H:%M:%S")] Limpeza de backups antigos concluída." | tee -a "$LOG_FILE"
