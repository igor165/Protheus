#INCLUDE "AGRX500.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//===================================================================================
/*****  Funções relacionadas - Romaneios - Grava Movimentações OGA440 *****/
//===================================================================================


/*/{Protheus.doc} A500GrvMov
//Função para gravar movimentação na rotina do OG (OGA440)
@author marina.muller
@since 07/05/2018
@version 1.0
@return ${return}, ${return_description}
@param cNKMTpMv, characters, descricao
@type function
/*/
Function A500GrvMov(cNKMTpMv, cFilRom, cCodRom)
	Local cMsg	:= ''
	Local lRet  := .T.

	If Empty(_cIdMV)
	   oMdlNKM := FWLoadModel( "OGA440" )
	   
	   oMdlNKM:SetOperation( MODEL_OPERATION_INSERT )
	   oMdlNKM:Activate()
	   oNKM:= oMdlNKM:GetModel( "NKMUNICO" )

		lRet:= oNKM:SetValue("NKM_FILIAL", fwXfilial("NKM"))
		lRet:= oNKM:SetValue("NKM_TIPOMV", cNKMTpMv)
		lRet:= oNKM:SetValue("NKM_STATUS", "2")  //2=Encerrada                                                                                                

		If ( lRet:=oMdlNKM:VldData() )
			oMdlNKM:CommitData()
		   _cIdMV := FWFLDGET('NKM_IDMOV')   // Identificando o Id do Movto a Ser Gerado
		Else
			cMsg := oMdlNKM:GetErrorMessage()[3] + oMdlNKM:GetErrorMessage()[6]
			Help( ,,STR0007,,cMsg, 1, 0 ) //"Ajuda"
		EndIf
	    oMdlNKM:DeActivate()
	EndIf    
	
    If lRet .And. !Empty(_cIdMV)
	   DbSelectArea("NJM")
	   NJM->(dbSetOrder(1))
	  
   	   If NJM->(MsSeek(cFilRom+cCodRom)) //filial+código romaneio
   	      If RecLock( "NJM", .F. )
   	         NJM->NJM_IDMOV := _cIdMV 
   	         NJM->(msUnLock()) 
	   	  Else
	   	  	 Help( ,, STR0042,, STR0050, 1, 0) //'Erro'###"Não encontrou romaneio para atualizar ID da movimentação OG."
	   	     lRet := .F.
	   	  EndIf
	   EndIf	  
	   NJM->( DbCloseArea())
	EndIf   

Return lRet 
