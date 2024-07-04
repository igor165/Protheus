#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "FILEIO.CH"

/*/{Protheus.doc} GTPT001TRA   
    chama o wizard de transmissão
    @type  Static Function
    @author Fernando Amorim(Cafu)
    @since 22/09/2017
    @version version
   
    @example
    (examples)
    @see (links_or_references)
/*/
Function GTPC853PRINT()

If H61->H61_STATRA $ '2|4' .AND. H61->H61_STATUS != '4'
	H61PRINT()
Else
	FwAlertHelp("STATUS","Apenas CTEOS transmitidas podem imprimir o DACTE-OS.")
Endif

Return()
