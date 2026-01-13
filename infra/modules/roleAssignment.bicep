@description('Principal ID to assign the role to')
param principalId string

@description('Role definition ID')
param roleDefinitionId string

@description('Resource ID to scope the role assignment to')
param resourceId string

// Parse resource ID to get the ACR resource
resource acrResource 'Microsoft.ContainerRegistry/registries@2023-07-01' existing = {
  name: split(resourceId, '/')[8]
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: acrResource
  name: guid(resourceId, principalId, roleDefinitionId)
  properties: {
    principalId: principalId
    roleDefinitionId: roleDefinitionId
    principalType: 'ServicePrincipal'
  }
}

@description('The ID of the role assignment')
output roleAssignmentId string = roleAssignment.id
