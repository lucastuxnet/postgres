# Script para automação do processo diário de backup

## Dar permissão no arquivo postgres

chmod +x postgres.sh

## Rodar o script

./postgres.sh

## Para adicionar no agendamento do linux.

crontab -e

## Horário para backup estipulado as 2 horas da manhã.

0 2 * * * /home/esolvere/universe/backup/backup_postgresql.sh
