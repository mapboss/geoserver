#!/usr/bin/env groovy
import groovy.xml.*

@Grab(group='org.jasypt', module='jasypt', version='1.9.2')
import org.jasypt.util.password.StrongPasswordEncryptor

/*
 * Encodes passwords similar to GeoServer (using StrongPasswordEncryptor).
 *
 * see https://github.com/geoserver/geoserver/blob/master/src/main/src/main/java/org/geoserver/security/password/GeoServerDigestPasswordEncoder.java
 */
class GeoServerDigest {

  final StrongPasswordEncryptor encryptor

  GeoServerDigest() {
    encryptor = new StrongPasswordEncryptor();
  }

  String convertPassword(String passwd) {
    if (!passwd) {
      // no password provided
      null
    }
    else if (passwd.startsWith('digest1:')) {
      // use as provided
      passwd
    }
    else if (passwd.startsWith('plain:')) {
      // create digest password
      passwd = passwd[6..-1]
      'digest1:' + encryptor.encryptPassword(passwd)
    }
    else {
      // assume plain password
      'digest1:' + encryptor.encryptPassword(passwd)
    }
  }

}

// definitions
basePath = new File(args[0])

def setDefaultPasswords() {
  def passwords = new GeoServerDigest()

  // Passwords are expected to be in the pattern expected by GeoServer
  // with either "digest1:..." or "plain:..." or as a plain password
  def masterPasswd = passwords.convertPassword(System.env.GS_MASTER_PASSWORD)
  def adminPasswd = passwords.convertPassword(System.env.GS_ADMIN_PASSWORD)
  if (!masterPasswd) {
    masterPasswd = adminPasswd
  }

  /*
   * Set admin password
   */

  def usersFile = new File(basePath, 'data/security/usergroup/default/users.xml')
  if (adminPasswd) {
    println 'Setting admin password'
    
    def parser = new XmlParser(false, true)
    def userRegistry = parser.parseText(usersFile.text)

    boolean updatedUser = false
    def adminUser = userRegistry.users.user.each { user ->
      if (user.@name == 'admin') {
        user.@password = adminPasswd
        updatedUser = true
      }
    }

    if (!updatedUser) {
      def users = userRegistry.users[0] ?: parser.createNode(userRegistry, new QName('users'), [:])
      parser.createNode(
        users, new QName('user'), [enabled: 'true', name: 'admin', password: adminPasswd]
      )
    }

    usersFile.text = XmlUtil.serialize(userRegistry)
  }

  /*
   * Set master password
   */
  
  //XXX what about keystore? needed to recreated / change password?

  def masterFileDigest = new File(basePath, 'data/security/masterpw.digest')
  if (masterPasswd) {
    if (masterPasswd.startsWith('digest1:')) {
      masterFileDigest.text = masterPasswd
      println "Master password set (digest1)"
    }
    else {
      throw new IllegalStateException('Unrecognized/unsupported master password pattern')
    }
  }
}

// actions
setDefaultPasswords()
