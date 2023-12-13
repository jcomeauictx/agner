import subprocess, logging
logging.basicConfig(level=logging.DEBUG if __debug__ else logging.WARNING)

def check_call(*args, **kwargs):
    '''
    use subprocess `check_call` but show what's going on
    '''
    logging.debug('call: %s', args)
    return subprocess.check_call(*args, **kwargs)

def check_output(*args, **kwargs):
    '''
    use subprocess `check_call` but show what's going on
    '''
    logging.debug('call: %s', args)
    return subprocess.check_output(*args, **kwargs)
