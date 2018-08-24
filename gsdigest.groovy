#!/usr/bin/env groovy

@Grab(group='org.jasypt', module='jasypt', version='1.9.2')
import org.jasypt.util.password.StrongPasswordEncryptor

def password = args[0]
def encryptor = new StrongPasswordEncryptor()

println 'digest1:' + encryptor.encryptPassword(password)
