#!/usr/bin/env groovy
import groovy.xml.*

// definitions
basePath = new File(args[0])

def updateWfsConfiguration() {
  def file = new File(basePath, 'data/wfs.xml')

  def parser = new XmlParser(false, true)
  def wfsConfig = parser.parseText(file.text)

  /*
   * Following the recommended settings as documented on
   * http://docs.geoserver.org/latest/en/user/data/app-schema/wfs-service-settings.html
   */

  // make sure canoncial schema location is enabled
  // <canonicalSchemaLocation>true</canonicalSchemaLocation>
  def canonicalSchemaLocation = wfsConfig.canonicalSchemaLocation[0] ?: parser.createNode(
    wfsConfig, new QName('canonicalSchemaLocation'), [:]
  )
  canonicalSchemaLocation.value = true

  // <encodeFeatureMember>true</encodeFeatureMember>
  def encodeFeatureMember = wfsConfig.encodeFeatureMember[0] ?: parser.createNode(
    wfsConfig, new QName('encodeFeatureMember'), [:]
  )
  encodeFeatureMember.value = true

  file.text = XmlUtil.serialize(wfsConfig)
}


// actions
updateWfsConfiguration()
