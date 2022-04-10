import json
import yaml
import os

from pathlib import Path
from typing import Dict, Any, List

TEAM_CONFIG_DIR = os.fsencode("config/teams")
OUTPUT_DIR = f"./modules/init-snowflake/tmp"


def create_resources() -> Dict[str, Any]:
    """
    :return: a dict containing required snowflake resources for each team
    """
    team_resources = {'teams': []}
    for file in os.listdir(TEAM_CONFIG_DIR):
        file_path = f"{os.fsdecode(TEAM_CONFIG_DIR)}/{os.fsdecode(file)}"
        with open(file_path) as f:
            team_config = yaml.load(f, Loader=yaml.FullLoader)
            team = {'domain': team_config['domain'].upper(), 'name': team_config['team'].upper()}
            roles = [{'name': f'{team["name"]}_ADMIN', 'comment': f'{team["name"]} administrative user'},
                     {'name': f'{team["name"]}_ANALYST',
                      'comment': f'{team["name"]} user with limited write permissions'},
                     {'name': f'{team["name"]}_READ', 'comment': f'{team["name"]} read-only user'}]
            warehouses = [
                {'name': f'{team["name"]}_WH', 'quota': team_config['quota'], 'resource_monitor': f'{team["name"]}_WH',
                 'auto_suspend': team_config['auto_suspend']}]
            databases = [{'name': f'{team["name"]}_DB', 'tags': {'name': 'domain', 'value': team_config['domain']}}]

            # Optional Resources
            additional_warehouses = []
            for warehouse in team_config['additional_warehouses']:
                if not warehouse['name'].upper().startswith(team["name"]):
                    print(f'ERROR: For team [{team["name"]}], additional warehouse name must start with the team name!')
                    exit(1)
                additional_warehouses.append({'name': f"{warehouse['name'].upper()}",
                                              'quota': warehouse['quota'],
                                              'resource_monitor': f"{warehouse['name'].upper()}",
                                              'auto_suspend': warehouse['auto_suspend']})
            warehouses += additional_warehouses

            additional_databases = []
            for database in team_config['additional_databases']:
                if not database['name'].upper().startswith(team["name"]):
                    print(f'ERROR: For team [{team["name"]}], additional database name must start with the team name!')
                    exit(1)
                additional_databases.append(
                    {'name': database['name'].upper(), 'tags': {'name': 'domain', 'value': team_config['domain']}})
            databases += additional_databases

            # Final dict
            team['warehouses'] = warehouses
            team['databases'] = databases
            team['roles'] = roles
            team['rsa_users'] = create_rsa_users()
            team['azure_apps'] = create_azure_application_assignments()
            team_resources['teams'] += [team]

    return team_resources


def create_role_grants() -> Dict[str, List[str]]:
    """
    :return:
    """
    grants_to_roles = {'TASKADMIN': ['SYSADMIN'],
                       }
    for file in os.listdir(TEAM_CONFIG_DIR):
        file_path = f"{os.fsdecode(TEAM_CONFIG_DIR)}/{os.fsdecode(file)}"
        with open(file_path) as f:
            config = yaml.load(f, Loader=yaml.FullLoader)
            team_name = config['team'].upper()

            # Team Grants - key: role being granted, value list of roles to grant to
            grants_to_roles[f'{team_name}_ADMIN'] = ['SYSADMIN']
            grants_to_roles[f'{team_name}_ANALYST'] = [f'{team_name}_ADMIN']
            grants_to_roles[f'{team_name}_READ'] = [f'{team_name}_ADMIN', f'{team_name}_ANALYST']
            grants_to_roles['TASKADMIN'].append(f'{team_name}_ADMIN')

            # Additional Grants
            for role_name in config['additional_role_grants']['admin']:
                if role_name not in grants_to_roles.keys():
                    grants_to_roles[role_name] = [f'{team_name}_ADMIN']
                else:
                    grants_to_roles[role_name].append(f'{team_name}_ADMIN')
            for role_name in config['additional_role_grants']['analyst']:
                if role_name not in grants_to_roles.keys():
                    grants_to_roles[role_name] = [f'{team_name}_ANALYST']
                else:
                    grants_to_roles[role_name].append(f'{team_name}_ANALYST')
            for role_name in config['additional_role_grants']['user']:
                if role_name not in grants_to_roles.keys():
                    grants_to_roles[role_name] = [f'{team_name}_READ']
                else:
                    grants_to_roles[role_name].append(f'{team_name}_READ')

    return grants_to_roles


def create_database_grants() -> List[Dict[str, Any]]:
    """

    :return:
    """
    database_grants = []
    for file in os.listdir(TEAM_CONFIG_DIR):
        file_path = f"{os.fsdecode(TEAM_CONFIG_DIR)}/{os.fsdecode(file)}"
        with open(file_path) as f:
            config = yaml.load(f, Loader=yaml.FullLoader)
            team_name = config['team'].upper()
            share_roles = []

            # Team Database Grants
            usage_roles = share_roles + [f'{team_name}_ADMIN', f'{team_name}_ANALYST', f'{team_name}_READ']
            monitor_roles = share_roles + [f'{team_name}_ADMIN', f'{team_name}_ANALYST']
            create_schema_roles = [f'{team_name}_ADMIN']
            database_grants.append(
                {'database_privilege': f'{team_name}_DB_USAGE', 'roles': usage_roles,
                 'with_grant_option': True})
            database_grants.append(
                {'database_privilege': f'{team_name}_DB_MONITOR', 'roles': monitor_roles,
                 'with_grant_option': True})
            database_grants.append(
                {'database_privilege': f'{team_name}_DB_CREATE_SCHEMA', 'roles': create_schema_roles,
                 'with_grant_option': True})

            # Additional Database Grants
            usage_roles = share_roles + [f'{team_name}_ADMIN', f'{team_name}_ANALYST', f'{team_name}_READ']
            monitor_roles = share_roles + [f'{team_name}_ADMIN', f'{team_name}_ANALYST']
            create_schema_roles = [f'{team_name}_ADMIN']
            for database in config['additional_databases']:
                database_grants.append(
                    {'database_privilege': f'{database["name"].upper()}_USAGE', 'roles': usage_roles,
                     'with_grant_option': True})
                database_grants.append(
                    {'database_privilege': f'{database["name"].upper()}_MONITOR', 'roles': monitor_roles,
                     'with_grant_option': True})
                database_grants.append(
                    {'database_privilege': f'{database["name"].upper()}_CREATE_SCHEMA', 'roles': create_schema_roles,
                     'with_grant_option': True})
    return database_grants


def create_warehouse_grants() -> List[Dict[str, Any]]:
    """

    :return:
    """
    warehouse_grants = []
    for file in os.listdir(TEAM_CONFIG_DIR):
        file_path = f"{os.fsdecode(TEAM_CONFIG_DIR)}/{os.fsdecode(file)}"
        with open(file_path) as f:
            config = yaml.load(f, Loader=yaml.FullLoader)
            team_name = config['team'].upper()

            # Team Warehouse Grants
            operate_roles = [f'{team_name}_ADMIN', f'{team_name}_ANALYST', f'{team_name}_READ']
            monitor_roles = [f'{team_name}_ADMIN', f'{team_name}_ANALYST', f'{team_name}_READ']
            modify_roles = [f'{team_name}_ADMIN', f'{team_name}_ANALYST']
            usage_roles = [f'{team_name}_ADMIN', f'{team_name}_ANALYST', f'{team_name}_READ']
            warehouse_grants.append(
                {'warehouse_privilege': f'{team_name}_WH_OPERATE', 'roles': operate_roles,
                 'with_grant_option': False})
            warehouse_grants.append(
                {'warehouse_privilege': f'{team_name}_WH_MONITOR', 'roles': monitor_roles,
                 'with_grant_option': False})
            warehouse_grants.append(
                {'warehouse_privilege': f'{team_name}_WH_MODIFY', 'roles': modify_roles,
                 'with_grant_option': False})
            warehouse_grants.append(
                {'warehouse_privilege': f'{team_name}_WH_USAGE', 'roles': usage_roles,
                 'with_grant_option': False})

            # Additional Warehouse Grants
            operate_roles = [f'{team_name}_ADMIN']
            monitor_roles = [f'{team_name}_ADMIN']
            modify_roles = [f'{team_name}_ADMIN']
            usage_roles = [f'{team_name}_ADMIN']
            for warehouse in config['additional_warehouses']:
                warehouse_grants.append(
                    {'warehouse_privilege': f'{warehouse["name"].upper()}_OPERATE', 'roles': operate_roles,
                     'with_grant_option': False})
                warehouse_grants.append(
                    {'warehouse_privilege': f'{warehouse["name"].upper()}_MONITOR', 'roles': monitor_roles,
                     'with_grant_option': False})
                warehouse_grants.append(
                    {'warehouse_privilege': f'{warehouse["name"].upper()}_MODIFY', 'roles': modify_roles,
                     'with_grant_option': False})
                warehouse_grants.append(
                    {'warehouse_privilege': f'{warehouse["name"].upper()}_USAGE', 'roles': usage_roles,
                     'with_grant_option': False})
    return warehouse_grants


def create_resource_monitor_grants() -> List[Dict[str, Any]]:
    """

    :return:
    """
    resource_monitor_grants = []
    for file in os.listdir(TEAM_CONFIG_DIR):
        file_path = f"{os.fsdecode(TEAM_CONFIG_DIR)}/{os.fsdecode(file)}"
        with open(file_path) as f:
            config = yaml.load(f, Loader=yaml.FullLoader)
            team_name = config['team'].upper()

            # Team Resource Monitor Grants
            monitor_roles = [f'{team_name}_ADMIN']
            resource_monitor_grants.append(
                {'resource_monitor_privilege': f'{team_name}_WH_MONITOR', 'roles': monitor_roles,
                 'with_grant_option': False})

            # Additional Resource Monitor Grants
            for warehouse in config['additional_warehouses']:
                resource_monitor_grants.append(
                    {'resource_monitor_privilege': f'{warehouse["name"].upper()}_MONITOR', 'roles': monitor_roles,
                     'with_grant_option': False})
    return resource_monitor_grants


def create_global_resources() -> Dict[str, Any]:
    """
    :return: a dict
    """
    global_roles = [{'name': 'TASKADMIN', 'comment': 'Role gives capability to create Snowflake Tasks.'},
                    ]

    global_resources = {'roles': global_roles}

    return global_resources


def create_rsa_users() -> List[Dict[str, Any]]:
    """

    :return:
    """
    rsa_key_users = []
    for file in os.listdir(TEAM_CONFIG_DIR):
        file_path = f"{os.fsdecode(TEAM_CONFIG_DIR)}/{os.fsdecode(file)}"
        with open(file_path) as f:
            config = yaml.load(f, Loader=yaml.FullLoader)
            team_name = config['team'].upper()

            if 'rsa_key_users' in config and len(config['rsa_key_users']) != 0:
                for user in config['rsa_key_users']:
                    if not user['name'].upper().startswith(team_name):
                        print(f"ERROR: For team [{team_name}], rsa_key_user name must start with the team name!")
                        exit(1)
                    if 'default_role' in user and not user['default_role'].upper().startswith(team_name):
                        print(f"ERROR: For team [{team_name}], default_role must start with the team name!")
                        exit(1)
                    if 'default_wh' in user and not user['default_wh'].upper().startswith(team_name):
                        print(f"ERROR: For team [{team_name}], default_wh must start with the team name!")
                        exit(1)
                    default_role = user['default_role'] if 'default_role' in user else f"{team_name.upper()}_ADMIN"
                    default_wh = user['default_wh'] if 'default_wh' in user else f"{team_name.upper()}_WH"
                    rsa_key2 = user['rsa_key2'] if 'rsa_key2' in user else ''
                    comment = f"rsa key user for team {team_name}"
                    rsa_key_users.append({'name': f"{user['name'].upper()}",
                                          'rsa_key1': user['rsa_key1'],
                                          'rsa_key2': rsa_key2,
                                          'default_role': default_role,
                                          'default_wh': default_wh,
                                          'comment': comment})
    return rsa_key_users


def create_azure_application_assignments() -> List[Dict[str, Any]]:
    """

    :return:
    """
    app_assignments = []
    for file in os.listdir(TEAM_CONFIG_DIR):
        file_path = f"{os.fsdecode(TEAM_CONFIG_DIR)}/{os.fsdecode(file)}"
        with open(file_path) as f:
            config = yaml.load(f, Loader=yaml.FullLoader)
            team_name = config['team'].upper()

            if 'azure_oauth_application_ids' in config and len(config['azure_oauth_application_ids']) != 0:
                for application_id in config['azure_oauth_application_ids']:
                    app_assignments.append({'app_role': f"session:role:{team_name}_admin".lower(),
                                            'app_id': application_id})
    return app_assignments


if __name__ == '__main__':
    team_configs = {'global_resources': create_global_resources(),
                    'resources': create_resources(),
                    'database_grants': create_database_grants(),
                    'resource_monitor_grants': create_resource_monitor_grants(),
                    'role_grants': create_role_grants(),
                    'warehouse_grants': create_warehouse_grants()
                    }
    Path(OUTPUT_DIR).mkdir(exist_ok=True)
    with open(f'{OUTPUT_DIR}/config.json', 'w') as f:
        json.dump(team_configs, f)
    print(f"generated {os.path.abspath(f'{OUTPUT_DIR}/config.json')}")
