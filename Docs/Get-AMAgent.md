---
external help file: AutoMatePS-help.xml
Module Name: AutoMatePS
online version: https://github.com/davidseibel/AutoMatePS
schema: 2.0.0
---

# Get-AMAgent

## SYNOPSIS
Gets AutoMate Enterprise agents.

## SYNTAX

### All (Default)
```
Get-AMAgent [[-Name] <String>] [-Type <AMAgentType>] [-FilterSet <Hashtable[]>] [-FilterSetMode <String>]
 [-SortProperty <String[]>] [-SortDescending] [-Connection <Object>] [<CommonParameters>]
```

### ByPipeline
```
Get-AMAgent [-InputObject <Object>] [[-Name] <String>] [-Type <AMAgentType>] [-FilterSet <Hashtable[]>]
 [-FilterSetMode <String>] [-SortProperty <String[]>] [-SortDescending] [-Connection <Object>]
 [<CommonParameters>]
```

### ByID
```
Get-AMAgent [[-Name] <String>] [-ID <String>] [-Type <AMAgentType>] [-FilterSet <Hashtable[]>]
 [-FilterSetMode <String>] [-SortProperty <String[]>] [-SortDescending] [-Connection <Object>]
 [<CommonParameters>]
```

## DESCRIPTION
Get-AMAgent gets agent objects from AutoMate Enterprise. 
Get-AMAgent can receive items on the pipeline and return related objects.

## EXAMPLES

### EXAMPLE 1
```
# Get agent "agent01"
```

Get-AMAgent "agent01"

### EXAMPLE 2
```
# Get agents in agent group "group01"
```

Get-AMAgentGroup "group01" | Get-AMAgent

### EXAMPLE 3
```
# Get agents configured within any workflow for the condition "My Condition"
```

Get-AMCondition "My Condition" | Get-AMAgent

### EXAMPLE 4
```
# Get agents using filter sets
```

Get-AMAgent -FilterSet @{ Property = "Enabled"; Comparator = "="; Value = "true"}

## PARAMETERS

### -InputObject
The object(s) to use in search for agents.

```yaml
Type: Object
Parameter Sets: ByPipeline
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Name
The name of the agent (case sensitive). 
Wildcard characters can be escaped using the \` character. 
If using escaped wildcards, the string
must be wrapped in single quotes. 
For example: Get-AMAgent -Name '\`\[Test\`\]'

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ID
The ID of the agent.

```yaml
Type: String
Parameter Sets: ByID
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Type
The type of agent.

```yaml
Type: AMAgentType
Parameter Sets: (All)
Aliases:
Accepted values: Unknown, TaskAgent, ProcessAgent, All

Required: False
Position: Named
Default value: All
Accept pipeline input: False
Accept wildcard characters: False
```

### -FilterSet
The parameters to filter the search on. 
Supply hashtable(s) with the following properties: Property, Comparator, Value.
Valid values for the Comparator are: =, !=, \<, \>, contains (default - no need to supply Comparator when using 'contains')

```yaml
Type: Hashtable[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FilterSetMode
If multiple filter sets are provided, FilterSetMode determines if the filter sets should be evaluated with an AND or an OR

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: And
Accept pipeline input: False
Accept wildcard characters: False
```

### -SortProperty
The object property to sort results on. 
Do not use ConnectionAlias, since it is a custom property added by this module, and not exposed in the API.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: Name
Accept pipeline input: False
Accept wildcard characters: False
```

### -SortDescending
If specified, this will sort the output on the specified SortProperty in descending order. 
Otherwise, ascending order is assumed.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Connection
The AutoMate Enterprise management server.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### Agents related to the following objects can be retrieved by this function:
Workflow
Task
Condition
Process
AgentGroup
Folder
Instance

## OUTPUTS

### Agent

## NOTES
Author(s):     : David Seibel
Contributor(s) :
Date Created   : 07/26/2018
Date Modified  : 08/08/2018

## RELATED LINKS

[https://github.com/davidseibel/AutoMatePS](https://github.com/davidseibel/AutoMatePS)
