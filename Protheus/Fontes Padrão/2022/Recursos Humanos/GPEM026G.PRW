#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GPEM026.CH"

/*/{Protheus.doc} fInt2416New
Geração do events S-2416 Beneficiarios Orgãos Publicos
@author raquel.andrade
@since 15/10/2021
@version P12
@Type     Function
/*/
Function fInt2416New(oModel,aErros)
Local oMdl		:= oModel:GetModel("GPEA019_RI0")
Local aArea		:= GetArea()
Local aFilInTaf	:= {}
Local lGravou 	:= .T.    
Local cFilEnv	:= "" 
Local cDsc		:= "" 
Local cIndSup	:= ""
Local cTpMorte	:= ""
Local cMtvSusp	:= ""
Local cDscSusp	:= ""
Local cXml		:= ""

Default oModel		:= Nil
Default aErros		:= {}
			
	fGp23Cons(@aFilInTaf, {cFilAnt}, @cFilEnv)	
	If Empty(cFilEnv)
		cFilEnv:= cFilAnt
	EndIf

	Begin Transaction		
		If !(Empty(cFilEnv))

			//Início da Geração do XML - Geração do registro S-2416			
			cXml += '<eSocial>'
			cXml += '	<evtCdBenAlt>'
			cXml += '		<ideBeneficio>'
			cXml += '			<cpfBenef>'    	+ RI0->RI0_CPF	+ '</cpfBenef>'
			cXml += '			<nrBeneficio>'    	+ RI0->RI0_NRBEN	+ '</nrBeneficio>'
			cXml += '		</ideBeneficio>'
			cXml += '		<infoBenAlteracao>'  
			cXml += '			<dtAltBeneficio>' + DtoS(oMdl:GetValue("RI0_DTAS"))  + '</dtAltBeneficio>' 
			cXml += '			<dadosBeneficio>' 

			cXml += '				<tpBeneficio>' + oMdl:GetValue("RI0_TPBEN") + '</tpBeneficio>' 
			cXml += '				<tpPlanRP>' + oMdl:GetValue("RI0_TPPLAN")  + '</tpPlanRP>' 		
			cDsc	:= If(Empty(oMdl:GetValue("RI0_DSCMEM"))," ", AllTrim(oMdl:GetValue("RI0_DSCMEM")))	
			cXml += '				<dsc>'  + cDsc    + '</dsc>' 
			
			cIndSup	:= If (Empty(oMdl:GetValue("RI0_INDSUP")), "N", If(oMdl:GetValue("RI0_INDSUP") == "1", "S","N"))
			cXml += '				<indSuspensao>'  + cIndSup + '</indSuspensao>' 

			cXml += '				<infoPenMorte>' 
			cTpMorte	:= If(Empty(oMdl:GetValue("RI0_TPMORT"))," ", oMdl:GetValue("RI0_TPMORT"))
			cXml += '					<tpPenMorte>' + cTpMorte + '</tpPenMorte>' 
			cXml += '				</infoPenMorte>'

			cXml += '				<suspensao>' 
			cMtvSusp	:= If(Empty(oMdl:GetValue("RI0_MOTSUP"))," ", oMdl:GetValue("RI0_MOTSUP"))
			cDscSusp	:= If(Empty(oMdl:GetValue("RI0_DSSUPM"))," ", AllTrim(oMdl:GetValue("RI0_DSSUPM")))
			cXml += '					<mtvSuspensao>' + cMtvSusp + '</mtvSuspensao>' 
			cXml += '					<dscSuspensao>' + cDscSusp  + '</dscSuspensao>' 				  
			cXml += '				</suspensao>'

			cXml += '			</dadosBeneficio>'
			cXml += '		</infoBenAlteracao>'		
			cXml += '	</evtCdBenAlt>'   
			cXml += '</eSocial>'	
			//Fim do XML

			//Realiza geração de XML na System
			GrvTxtArq(AllTrim(cXml), "S-2416")

			//Aguardando o tratamento do TAF para o evento S-2416				
			aErros := TafPrepInt( cEmpAnt, cFilEnv, cXml, ,"1", "S-2416",,,,,,"GPE", SRA->RA_FILIAL,,,cEmpAnt, , , , , )			
			If Len( aErros ) > 0					
				lGravou := .F.
			EndIf			
		EndIf
	
	End Transaction

	RestArea(aArea)
	
Return lGravou

