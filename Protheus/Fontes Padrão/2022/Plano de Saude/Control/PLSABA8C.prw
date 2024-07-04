#INCLUDE "PLSABA8C.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Define.
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
#DEFINE PLS__ALIAS_BA8	"BA8"
#DEFINE PLS__ALIAS_BD4	"BD4"
#DEFINE PLS__ALIAS_BDY	"BDY"

#DEFINE PLS_MOD_BA8		"PLSABA8M"
#DEFINE PLS_MOD_BD4		"PLSABD4M"
#DEFINE PLS_MOD_BDY		"PLSABDYM"

#DEFINE PLS_MD__IDBA8  	"PLSABA8MMD"
#DEFINE PLS_VW__IDBA8  	"PLSABA8MVI"

#DEFINE PLS_MD__IDBD4 	"PLSABD4MMD"
#DEFINE PLS_VW__IDBD4 	"PLSABD4MVI"

#DEFINE PLS_MD__IDBDY 	"PLSABDYMMD"
#DEFINE PLS_VW__IDBDY 	"PLSABDYMVI"

#DEFINE PLS_VW_OPE	2
#DEFINE PLS_MD_OPE	1

/*/{Protheus.doc} PLSABA8C
Controle das classes

@author Alexander Santos

@since 11/02/2014
@version P11
/*/

class PLSABA8C from PLSCONTR

DATA cAlias	AS STRING

method New() Constructor   

method VWOkCloseScreenVLD(oView,lExiMsg)
method VWOkButtonVLD(oModel,cAlias)
method MDCommit(oModel,cAlias)
method MDPosVLD(oModel,cAlias)
method MDActVLD(oModel)
method MDLinePosVLD(oModel)
method MDLinePreVLD(oModel, nLine, cAction, cIDField, xValue, xCurrentValue)
method destroy()

method	 getFiltro()
method getCodPad()
method getTitulo(nOp)
method	 getAlias(nOp)
method	 getModel(nOp)
method	 getModelId(nOp)
method	 getViewId(nOp)
method	 getModelOperation()
method	 getViewOperation()
method getFolder()
method getlBDY()
 
endClass     

/*/{Protheus.doc} New
Construtor da class

@author Alexander Santos
@since 11/02/2014
@version P11
/*/
method New() class PLSABA8C
::cAlias := PLS__ALIAS_BA8
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Fim do metodo
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
return Self                  

/*/{Protheus.doc} MDPosVLD
Pos validacao do modelo de dados.

@author Alexander Santos
@since 11/02/14
@version 1.0
/*/
method MDPosVLD(oModel,cAlias) class PLSABA8C
local lRet 		:= .t.
local oGEN		:= nil
local oModelD 	:= oModel:getModel(oModel:getModelIds()[1])
local nOperation	:= oModelD:getOperation()
local cCodTab		:= ''
local cCodPad		:= ''
local cCodPro		:= ''
local aChave		:= {}

default cAlias 	:= ""
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Valida Model                     
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
do case
	case cAlias == 'BA8'
		cCodTab := oModelD:getValue("BA8_CODTAB")
		cCodPad := oModelD:getValue("BA8_CODPAD")
		cCodPro := oModelD:getValue("BA8_CODPRO")
		
		if nOperation == MODEL_OPERATION_DELETE 
		
			oGEN := PLSREGIC():New()
			oGEN:getDadReg("BF8",1, xFilial("BF8")+cCodTab,,,.f.)
			
			if !oGEN:lFound
			   	_Super:exbMHelp(STR0001) //"Verifique a integridade do BF8 com a BA8"
			   lRet := .f.
			endIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			//³ Na exclusao verifica integridade                                         
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			if lRet
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
				//³ verifica se pode excluir
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
				aadd(aChave, { "BA8_CODPAD", '=', cCodPad } )
				aadd(aChave, { "BA8_CODPRO", '=', cCodPro } )
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
				//³ verifica quantidade de registros e nao deixa excluir
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
				oGEN := PLSREGIC():New()
			   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			   //³ Se existe mais de 1 na tab de eventos pode excluir...                   
			   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
				if oGEN:getCountReg("BA8",aChave) > 1
					lRet := .t.
				else
					aChave := {}
					aadd(aChave,{"BAA","BAA_CODPRO",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BAQ","BAQ_CODPSA",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BB2","BB2_CODPSA",cCodPro}) 
					aadd(aChave,{"BB9","BB9_CODOPC",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BBM","BBM_CODPSA",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BBN","BBN_CODPSA",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BC0","BC0_CODOPC",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BC6","BC6_CODPRO",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BD6","BD6_CODPRO",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BD7","BD7_CODPRO",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BDI","BDI_CODPRO",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BDJ","BDJ_CODPRO",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BDN","BDN_CODOPC",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BDS","BDS_CODPRO",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BDU","BDU_CODPRO",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BDX","BDX_CODPRO",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BDY","BDY_CODPRO",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BDZ","BDZ_CODPSA",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BE2","BE2_CODPRO",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BE6","BE6_CODPRO",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BE9","BE9_CODPRO",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BEF","BEF_CODPRO",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BEH","BEH_CODPRO",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BEI","BEI_CODPRO",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BEJ","BEJ_CODPRO",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BFA","BFA_CODPSA",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BFD","BFD_CODPSA",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BFG","BFG_CODPSA",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BFP","BFP_CODPSA",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BG8","BG8_CODPSA",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BGD","BGD_CODPRO",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BGI","BGI_CODPRO",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BHD","BHD_CODPSA",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BHE","BHE_CODPSA",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BHK","BHK_CODPSA",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BI4","BI4_CODPRO",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BJ4","BJ4_CODPSA",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BKB","BKB_CODPSA",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BKE","BKE_CODPRO",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BKI","BKI_CODPRO",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BLD","BLD_CODPRO",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BLE","BLE_CODPRO",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BLE","BLE_CODOPC",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BLF","BLF_CODPRO",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BLF","BLF_CODOPC",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BLG","BLG_CODPRO",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BLH","BLH_CODPRO",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BLI","BLI_CODPRO",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BLK","BLK_CODPRO",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BLN","BLN_CODPRO",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BLN","BLN_CODOPC",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BLO","BLO_CODPRO",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BLO","BLO_CODOPC",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BLQ","BLQ_CODPRO",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BLQ","BLQ_CODOPC",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BLT","BLT_CODPSA",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BLU","BLU_CODPSA",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BLW","BLW_CODPSA",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BLX","BLX_CODPSA",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BLY","BLY_CODPRO",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BLY","BLY_CODOPC",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BLZ","BLZ_CODPRO",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BMC","BMC_CODPSA",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BME","BME_CODPSA",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BMG","BMG_CODPSA",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BMI","BMI_CODPSA",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BMM","BMM_CODPSA",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BMQ","BMQ_CODPRO",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BMT","BMT_CODPRO",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BMY","BMY_CODPSA",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BQJ","BQJ_CODPRO",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BQK","BQK_CODPRO",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BQM","BQM_CODPRO",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BQM","BQM_CODOPC",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BQN","BQN_CODPRO",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BQN","BQN_CODOPC",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BQO","BQO_CODPRO",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BQO","BQO_CODOPC",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BQV","BQV_CODPRO",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BSM","BSM_CODPRO",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BSU","BSU_CODPRO",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BSZ","BSZ_CODPRO",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BT8","BT8_CODPSA",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BTC","BTC_CODPSA",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BTW","BTW_CODPRO",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BV3","BV3_CODPSA",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BV4","BV4_CODPSA",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BV5","BV5_CODPSA",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BV6","BV6_CODPSA",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BV7","BV7_CODPSA",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BV8","BV8_CODPSA",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BVE","BVE_CODPSA",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BVF","BVF_CODPSA",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BVH","BVH_CODPSA",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BVM","BVM_CODPSA",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BVX","BVX_CODPRO",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BW3","BW3_CODPSA",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BWC","BWC_CODPSA",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BWF","BWF_CODPSA",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BWM","BWM_CODPSA",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BWM","BWM_CODPRO",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BXF","BXF_CODPRO",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BYQ","BYQ_CODPRO",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BYY","BYY_CODPRO",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BZB","BZB_CODOPC",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BZL","BZL_CODPSA",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BZM","BZM_CODPSA",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BZQ","BZQ_CODPSA",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BZR","BZR_CODPSA",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BZS","BZS_CODPSA",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BZT","BZT_CODPSA",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BZU","BZU_CODPSA",cCodPro})                                                                                                                                                      
					aadd(aChave,{"BZV","BZV_CODPSA",cCodPro})                                                                                                                                                      
				   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
				   //³ checa se e possivel excluir                   
				   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
					lRet := PLSCHKDEL(aChave)
					
					if !lRet
			   			_Super:exbMHelp(STR0002) //"Operação não Realizada!"
			   		endIf	
				endif   
			endIf	
			oGEN:destroy()
		
		elseIf nOperation == MODEL_OPERATION_INSERT

			oGEN := PLSREGIC():New()
			oGEN:getDadReg("BA8",1, xFilial("BA8")+cCodTab+cCodPad+cCodPro,,,.f.)
			
			if oGEN:lFound
			   	_Super:ExbMHelp("Registro existente!",,,"Pesquise o registro na lista.")
			   lRet := .f.
			endIf
			
			oGEN:destroy()
		endIf
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   //³ valida vigencias nao acionada no valid                  
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	case cAlias == 'BD4' .and. (nOperation == MODEL_OPERATION_INSERT .or. nOperation == MODEL_OPERATION_UPDATE)
	
		if FWFldGet('BA8_ANASIN',0,FWMODELACTIVE()) <> '2'
			
			lRet := PLBA8VldVi(oModelD:getValue("BD4_VIGINI"),oModelD:getValue("BD4_CODIGO"),'I')
			if lRet		
				lRet := PLBA8VldVi(oModelD:getValue("BD4_VIGFIM"),oModelD:getValue("BD4_CODIGO"),'F')
			endIf
			if lRet
				oGEN := PLSREGIC():new()
				oGEN:getDadReg("BD3",1, xFilial("BD3")+oModelD:getValue("BD4_CODIGO"))
				
				if oGEN:lFound
				   if oGEN:getValue('BD3_TIPVAL') $ "1, " .and. oModelD:getValue("BD4_VALREF") == 0
	  	              If ! MsgYesNo(STR0005,STR0006)//"Existem uma ou mais unidades com valor de referencia (BD4_VALREF) com valor igual ou menor que zero. Você deseja prosseguir com essa atualização?"##"Tabela de Honorários"
                         lRet := .F.
                      Else
                         lRet := .T.
                         PLShelp(STR0003) //"Para este lancamento o campo [BD4_VALREF] deve ser maior que zero"
                      Endif                 
				   endIf   
				endIf
				oGEN:destroy()
			endIf
		else
			lRet := .f.
		endIf		
					
endCase    
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Fim da Rotina															 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
return(lRet)               

/*/{Protheus.doc} MDCommit
Faz o commit necessario do modelo

@author Alexander Santos
@since 11/02/14
@version 1.0
/*/
method MDCommit(oModel,cAlias) class PLSABA8C
local aArea			:= (cAlias)->(getArea())
local nOpcP			:= 0
local oGEN 			:= nil
local oBR8 			:= nil
local oBF8 			:= nil
local oBA8 			:= nil
local oModelD 		:= oModel:getModel(oModel:getModelIds()[1])
local nOperation	:= oModel:getOperation()
local cCodTab		:= ''
local cCodPad		:= ''
local cCodPro		:= ''
local cAtivo		:= ''
local lNovo			:= .t.
local lExcEsp		:= .t.
local aChave		:= {}

do case
	case cAlias == 'BA8'
		cCodTab := oModelD:getValue("BA8_CODTAB")
		cCodPad := oModelD:getValue("BA8_CODPAD")
		cCodPro := oModelD:getValue("BA8_CODPRO")

		oBF8 := PLSREGIC():New()
		oBF8:getDadReg("BF8",1, xFilial("BF8")+cCodTab )
		
		if oBF8:lFound .and. oBF8:getValue("BF8_ESPTPD") == "1"
		
			oGEN := PLSREGIC():New()
			oGEN:getDadReg("BR8",1, xFilial("BR8")+cCodPad+cCodPro,,,.f.)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			//³ Espelhamento Tabela Padrao Saude...                                      
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			if oGEN:lFound
				lNovo	:= .f.
			else
				if nOperation == MODEL_OPERATION_DELETE
		     		lNovo	:= .f.
					lExcEsp:= .f.
				else
					lNovo	:= .t.
				endIf
			endIf
			oGEN:destroy()
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			//³ Se estiver deletando                     
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			if lExcEsp .and. nOperation == MODEL_OPERATION_DELETE
				aadd(aChave, { "BA8_CODPAD", '=', cCodPad } )
				aadd(aChave, { "BA8_CODPRO", '=', cCodPro } )
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
				//³ verifica quantidade de registros e nao deixa excluir
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
				oBA8 	:= PLSREGIC():New()
				lExcEsp:= !oBA8:getCountReg("BA8",aChave ) > 1
				oBA8:destroy()
			endIf	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			//³ Gravacao ou Alteracao dos atributos definidos no BR7 (para ficar aberto)...           
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			if nOperation == MODEL_OPERATION_INSERT .or. nOperation == MODEL_OPERATION_UPDATE
				
				BR7->(dbSetOrder(1))//BR7_FILIAL+BR7_FLDTDE
       			BR7->(msSeek(xFilial("BR7")))
					   
				nOpcP := iIf(nOperation == MODEL_OPERATION_INSERT,3,4)
				
				oBR8 := PLSSTRUC():New("BR8",iif(lNovo,MODEL_OPERATION_INSERT,MODEL_OPERATION_UPDATE),,BR8->(recno()) )

				while !BR7->(eof())
				
					if lNovo .and. BR7->BR7_PROCES $ "1,3"
						oBR8:setValue(AllTrim(BR7->BR7_FLDPSA),oModelD:getValue(AllTrim(BR7->BR7_FLDTDE)))
					else
						if	BR7->BR7_PROCES == "3"
							oBR8:setValue(AllTrim(BR7->BR7_FLDPSA),oModelD:getValue(AllTrim(BR7->BR7_FLDTDE)))
					
						elseIf BR7->BR7_PROCES == "2" .and. nOperation == MODEL_OPERATION_UPDATE
							oBR8:setValue(AllTrim(BR7->BR7_FLDPSA),oModelD:getValue(AllTrim(BR7->BR7_FLDTDE)))
					
						elseIf BR7->BR7_PROCES == "1" .and. nOperation == MODEL_OPERATION_INSERT .and. lNovo
							oBR8:setValue(AllTrim(BR7->BR7_FLDPSA),oModelD:getValue(AllTrim(BR7->BR7_FLDTDE)))
					
						endIf
					endIf
					
					BR7->(dbSkip())
				endDo
				       
				if lNovo
					cAtivo := strtran(strtran(alltrim(GetSx3Cache("BR8_BENUTL", "X3_RELACAO")),'"',""),"'","")
					if empty(cAtivo)
						cAtivo := "1"									
					endif
					oBR8:setValue("BR8_FILIAL",xFilial('BA8'))
					oBR8:setValue("BR8_BENUTL",cAtivo)
					oBR8:setValue("BR8_AUTORI","1")
				   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
				   //³ variavel __tpProc usada pelo layout simpro                   
				   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
					if valType(__tpProc) <> "U" .and. !empty(__tpProc)
 						oBR8:setValue("BR8_TPPROC",__tpProc)
 					else	
	 					oBR8:setValue("BR8_TPPROC",BF8->BF8_TPPROC)
	 				endIf	
				endIf             
		
				oBR8:CRUD()   
				oBR8:destroy()
				 			
			elseIf nOperation == MODEL_OPERATION_DELETE .and. lExcEsp
				nOpcP := 5
				oBR8 := PLSSTRUC():New("BR8",MODEL_OPERATION_DELETE,,BR8->(recno()) )
				oBR8:CRUD()   
				oBR8:destroy() 			
			   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			   //³ deleta BD4 e BDY                   
			   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
				BD4->(dbSetOrder(1))//BD4_FILIAL+BD4_CODTAB+BD4_CDPADP+BD4_CODPRO+BD4_CODIGO+DTOS(BD4_VIGINI)
				if BD4->(msSeek(xFilial("BD4")+BA8->(BA8_CODTAB+BA8_CDPADP+BA8_CODPRO)))
	
					while !BD4->(eof()) .and. xFilial("BD4")+BD4->(BD4_CODTAB+BD4_CDPADP+BD4_CODPRO) == xFilial("BA8")+BA8->(BA8_CODTAB+BA8_CDPADP+BA8_CODPRO)
						
						oGEN := PLSSTRUC():new("BD4",MODEL_OPERATION_DELETE,,BD4->(recno()))
						oGEN:crud()   
							
					BD4->(dbSkip())
					endDo
					
					oGEN:destroy()                                               
			endIf
	
				BDY->(dbSetOrder(1))//BDY_FILIAL+BDY_CODTAB+BDY_CDPADP+BDY_CODPRO+BDY_CDTBPD+BDY_CDPRO
				if BDY->(msSeek(xFilial("BDY")+BA8->(BA8_CODTAB+BA8_CDPADP+BA8_CODPRO)))
	
					while !BDY->(eof()) .and. xFilial("BDY")+BDY->(BDY_CODTAB+BDY_CDPADP+BDY_CODPRO) == xFilial("BA8")+BA8->(BA8_CODTAB+BA8_CDPADP+BA8_CODPRO)
						
						oGEN := PLSSTRUC():new("BDY",MODEL_OPERATION_DELETE,,BDY->(recno()))
						oGEN:crud()   
							
					BDY->(dbSkip())
					endDo
					
					oGEN:destroy()                                               
				endIf
					
			endIf
		endIf
		oBF8:destroy()
		
	case cAlias == 'BD4' .and. nOperation == MODEL_OPERATION_INSERT
		oModelD:setValue('BD4_CODTAB',BA8->BA8_CODTAB)
		oModelD:setValue('BD4_CDPADP',BA8->BA8_CDPADP)
		oModelD:setValue('BD4_CODPRO',BA8->BA8_CODPRO)
	case cAlias == 'BDY' .and. nOperation == MODEL_OPERATION_INSERT
		oModelD:setValue('BDY_CODTAB',BA8->BA8_CODTAB)
		oModelD:setValue('BDY_CDPADP',BA8->BA8_CDPADP)
		oModelD:setValue('BDY_CODPRO',BA8->BA8_CODPRO)
endCase	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Commit 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
FWFormCommit(oModel)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Rest nas linhas do browse e na area										 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
(cAlias)->(restArea(aArea))                   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Fim da Rotina															 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
return(.t.)

/*/{Protheus.doc} MDActVLD
Validacao da Ativacao do modelo

@author Alexander Santos 
@since 11/02/14
@version 1.0
/*/
method MDActVLD(oModel) class PLSABA8C
local lRet := BA8->BA8_ANASIN == "1"     

if !lRet
	_Super:exbMHelp(STR0004) //"Operação permitida somente para evento ANALÍTICO!"
endIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Fim da Rotina															 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
return(lRet)

/*/{Protheus.doc} VWOkCloseScreenVLD
Ao fechar a tela validacao para fechar a tela ou nao .T. Fecha .F nao deixa fechar a tela

@author Alexander Santos
@since 11/02/14
@version 1.0
/*/
method VWOkCloseScreenVLD(oView) class PLSABA8C
local lRet := .t.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Fim da Rotina															 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
return(lRet)                          

/*/{Protheus.doc} VWOkButtonVLD
Ao precionar o botao faz validacao para fechar a tela ou nao .T. Fecha

@author Alexander Santos
@since 11/02/14
@version 1.0
/*/
method VWOkButtonVLD(oModel,cAlias) class PLSABA8C
local lRet 	 := .T.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Fim da Rotina															 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
return(lRet) 
                         
/*/{Protheus.doc} destroy
Libera da memoria o obj (Destroy)

@author Alexander Santos
@since 11/02/14
@version 1.0
/*/
method destroy() class PLSABA8C
freeObj(Self:self)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Fim da Rotina															 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
return

/*/{Protheus.doc} getFiltro
Retorna o filtro

@author Alexander Santos
@since 11/02/14
@version 1.0
/*/
method getFiltro() class PLSABA8C
local cFil := "BA8_FILIAL = '" + xFilial("BA8") + "' .AND. BA8_CODTAB = '" + BF8->(BF8_CODINT+BF8_CODIGO) + "' "
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Fim da Rotina															 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
return cFil

/*/{Protheus.doc} getCodPad
Retorna codPad

@author Alexander Santos
@since 11/02/14
@version 1.0
/*/
method getCodPad() class PLSABA8C
return(BF8->BF8_CODPAD)

/*/{Protheus.doc} getTitulo
Retorna Titulo da tela

@author Alexander Santos
@since 11/02/14
@version 1.0
/*/
method getTitulo(nOp) class PLSABA8C
local cDescricao	:= ""
default nOp := 0

if nOp == 0
	cDescricao := BA8->(allTrim(PLSRetTit("BA8"))+" [ "+allTrim(BF8->BF8_DESCM)+" ] ")
elseIf nOp == 1	
	cDescricao := PLSRetTit("BD4")
elseIf nOp == 2	
	cDescricao := PLSRetTit("BDY")
endIf	 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Fim da Rotina															 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
return(cDescricao)

/*/{Protheus.doc} MDLinePosVLD
Bloco de codigo para pos validacao da linha do grid

@author Alexander Santos
@since 11/02/14
@version 1.0
/*/
method MDLinePosVLD(oModel) class PLSABA8C
local lRet := .t.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Fim da Rotina															 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
return(lRet)

/*/{Protheus.doc} MDLinePreVLD
Bloco de cogido para pre validacao da linha de edicao

@author Alexander Santos
@since 11/02/14
@version 1.0
/*/
method MDLinePreVLD(oModel, nLine, cAction, cIDField, xValue, xCurrentValue) class PLSABA8C
local lRet := .t.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Fim da Rotina															 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
return(lRet)

/*/{Protheus.doc} getAlias
Retorna o alias

@author Alexander Santos
@since 11/02/14
@version 1.0
/*/
method getAlias(nOp) class PLSABA8C
local cAlias := ''
default nOp := 0

do case
	case nOp == 0
		cAlias := PLS__ALIAS_BA8
	case nOp == 1
		cAlias := PLS__ALIAS_BD4
	case nOp == 2
		cAlias := PLS__ALIAS_BDY
endCase
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Fim da Rotina															 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
return(cAlias)

/*/{Protheus.doc} getModel
Retorna o Modelo

@author Alexander Santos
@since 11/02/14
@version 1.0
/*/
method getModel(nOp) class PLSABA8C
local cRet := ''
default nOp := 0

do case 
	case nOp == 0
		cRet := PLS_MOD_BA8
	case nOp == 1
		cRet := PLS_MOD_BD4
	case nOp == 2
		cRet := PLS_MOD_BDY
endCase		

return(cRet)

/*/{Protheus.doc} getModelId
Retorna o Id do Modelo

@author Alexander Santos
@since 11/02/14
@version 1.0
/*/
method getModelId(nOp) class PLSABA8C
local cModel := ''
default nOp := 0

do case
	case nOp == 0
		cModel := PLS_MD__IDBA8
	case nOp == 1
		cModel := PLS_MD__IDBD4
	case nOp == 2
		cModel := PLS_MD__IDBDY
endCase
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Fim da Rotina															 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
return(cModel) 

/*/{Protheus.doc} getViewId
Retorna o Id da View

@author Alexander Santos
@since 11/02/14
@version 1.0
/*/
method getViewId(nOp) class PLSABA8C
local cView := ''
default nOp := 0

do case
	case nOp == 0
		cView := PLS_VW__IDBA8
	case nOp == 1
		cView := PLS_VW__IDBD4
	case nOp == 2
		cView := PLS_VW__IDBDY
endCase
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Fim da Rotina															 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
return(cView) 

/*/{Protheus.doc} getViewOperation
Retorna o Operacacao da View

@author Alexander Santos
@since 11/02/14
@version 1.0
/*/
method getViewOperation() class PLSABA8C
return PLS_VW_OPE

/*/{Protheus.doc} getModeloOperation
Retorna o Operacacao do Modelo

@author Alexander Santos
@since 11/02/14
@version 1.0
/*/
method getModelOperation() class PLSABA8C
return PLS_MD_OPE

/*/{Protheus.doc} getFolder
Retorna os FOLDERs

@author Alexander Santos
@since 11/02/14
@version 1.0
/*/
method getFolder() class PLSABA8C
local aFolder := {}

aadd(aFolder,::getTitulo(1))

if ::getlBDY()
	aadd(aFolder,::getTitulo(2))
endIf

return(aFolder)


/*/{Protheus.doc} getlBDY
Retorna se deve implementar a tabela BDY

@author Alexander Santos
@since 11/02/14
@version 1.0
/*/
method getlBDY() class PLSABA8C
local lBDY := BF8->BF8_ESPTPD == "0"

return(lBDY)

/*/{Protheus.doc} PLSABA8C
Somente para compilar a class

@author Alexander Santos
@since 11/02/14
@version 1.0
/*/
function PLSABA8C
return
