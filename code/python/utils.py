import logging
import yaml

def read_config(config_file):
    '''
    Reads the configuration yaml file.
    '''
    return yaml.safe_load(open(config_file, 'r'))


def setup_logging():
    '''
    Sets up the logging configuration.
    '''
    cfg = read_config('config/global_cfg.yaml')
    if cfg.get('log_file').lower() != 'stdout':
        log_file = cfg.get('log_file', None)
    else:
        log_file = None
    if cfg.get('log_level') != '':
        log_level = cfg.get('log_level', 'INFO').upper()
    else:
        log_level = 'INFO'
    
    logging.basicConfig(
        filename=log_file,
        level=log_level,
        format="%(levelname)s [%(asctime)s] %(message)s",
        datefmt="%Y-%m-%d %H:%M:%S"
    )
    log = logging.getLogger(__name__)
    return log