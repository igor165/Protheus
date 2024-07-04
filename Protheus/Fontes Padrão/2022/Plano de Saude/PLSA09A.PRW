STATIC oBrwB4A		:= NIL
STATIC oBrwPro		:= NIL
STATIC oBrwCri		:= NIL
STATIC oBrwEven		:= NIL
STATIC oEncAnexo		:= NIL
STATIC __cTipo     	:= "1"  
STATIC _xNrAut		:= ''
STATIC lInfRda	   	:= .F.
STATIC aAutFor  		:= {}
STATIC aDadCri  		:= {}
STATIC aCabCri  		:= {}
STATIC aTrbCri  		:= {}
STATIC aDentesFaces 	:= {}
STATIC aCdCores 		:= {}
STATIC aCabDf 		:= {}
STATIC aDadDf 		:= {}
STATIC aTrbDf 		:= {}
STATIC bImpGuia 		:= {|| PLS09AIm2()  }
STATIC aDadB43     	:= {}
STATIC aCabB43     	:= {}
STATIC aTrbB43     	:= {}
Static objCENFUNLGP := CENFUNLGP():New()

#include "PROTHEUS.CH"
#include "PLSMGER.CH"
#include "PLSMCCR.CH" 
#INCLUDE "COMMON.CH"
#INCLUDE "RWMAKE.CH"           	
#include "PLSA09A.CH"           	
#include 'FWMVCDEF.CH'

#define  K_VisOnline 	12                     
#define  K_Imprimir 	7                     
#define  K_ImpRec 		8                     
#define  K_Copiar		6                     
#define  K_Evolucao		14  
#define  K_BCOCON 8
#define  K_RADIO 88
#define  K_QUIMIO 89
#define  K_OPME 90

#define __aCdCri187 {"573",STR0007}//"Demanda por requerimento"
#define __aCdCri197 {"09P",STR0008}//"Habilita checagem de regra para procedimentos incompatíveis!"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ PLSA09A  ³ Autor ³ Daher		         ³ Data ³ 16.02.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ 															   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                                                 
Function PLSA09A(cFiltroSec)

LOCAL nI			:= 0
LOCAL aCores		:= {}
LOCAL cFiltro    	:= ""

PRIVATE aAutForAnx 	:= {}
PRIVATE aCodCriHis 	:= {}
PRIVATE aRotina   	:= MenuDef(@aCores)
PRIVATE cCadastro 	:= STR0009 //"Anexos Clinicos"
PRIVATE cNumProto   := Space(20)

PRIVATE cDesQtdAut := ''

DEFAULT cFiltroSec := ""

SX3->(DbSetOrder(2))
SX3->(DbSeek("B4C_QTDPRO"))
cDesQtdAut := AllTrim(X3Titulo("B4C_QTDPRO"))

cFiltro := PLS09AFIL(__cTipo)

If FindFunction("PLSRESTOP")
	cStrFil := PlsResTop("QR",.f.)
	If !(Empty(cStrFil))
		cFiltro += " .and. "+cStrFil
	EndIf
EndIf

DbSelectArea("B4A")
DbSetOrder(1)

If ExistBlock( "PL09AFIL" )
	cFiltro := ExecBlock( "PL09AFIL", .F., .F., {cFiltro} )
EndIf

cFiltro += " " + cFiltroSec
//===========================================================================
//³ Browse
//===========================================================================
oBrwB4A := FWmBrowse():New()
oBrwB4A:SetAlias('B4A')
oBrwB4A:SetDescription( cCadastro )
oBrwB4A:SetFilterDefault( cFiltro )
//===========================================================================
//³ Inclui legenda
//===========================================================================
if len(aCores)>0
	for nI:=1 to len(aCores)
		if ( nPos := aScan(aCdCores,{|x| x[1] == aCores[nI,2]}) ) > 0
			oBrwB4A:AddLegend( aCores[nI,1], aCores[nI,2], aCdCores[nPos,2] )
		endIf
	next
endif
oBrwB4A:activate()
//===========================================================================
//³ Fim da Rotina Principal...                                               ³
//===========================================================================

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ PLA09ASES  ³ Autor ³ Roberto Arruda       ³ Data ³ 04.05.17 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ 															   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Retorna as RDA's vinculadas ao login                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLA09ASES()

Local nQtdPrtd
Local nI
Local cCodPrt := ""

If type('HttpSession->RDAVIEW') == 'U' .and. type('HttpSession->USR_INFO') <> 'U'
	HttpSession->RDAVIEW := HttpSession->USR_INFO[1]:OWSUSERLOGPLS:OWSLISTOFRDA:OWSRDAVIEW //Prestador	
endif

nQtdPrtd := Len(HttpSession->RDAVIEW)

For nI := 1 To nQtdPrtd

	if nI < nQtdPrtd
		cCodPrt += HttpSession->RDAVIEW[nI]:CCODE+ "|M" //,
	Else
		cCodPrt += HttpSession->RDAVIEW[nI]:CCODE
	EndIf
	
Next

return cCodPrt

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ PLA09ALIB  ³ Autor ³ Daher		         ³ Data ³ 16.02.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ 															   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLA09ALIB(cDado,lWeb,aRetorno, cRDACode)
      
LOCAL cCampo 	:= ReadVar()
LOCAL lRet      := .F.
LOCAL cConteudo := "" 
LOCAL dDatAut 	:= cTOD('')
LOCAL cUsuari 	:= ''
LOCAL cCidPri 	:= ''
LOCAL cCidSec 	:= ''
LOCAL cCidTer 	:= ''
LOCAL cCidQua 	:= ''              
LOCAL cSenhaPls := ''
LOCAL aRet    	:= {}
LOCAL lInterProt:= .F.
LOCAL lFindBE4  := .F.
LOCAL cMatric   := ""
Local cMsgCri		:= ""
Local dDatRet   := getNewPar("MV_PLPRZLB",30) 

DEFAULT lWeb	:= .f.
DEFAULT aRetorno := {}
DEFAULT cRDACode := ""
//===========================================================================
//³ Somente se o conteudo foi informado
//===========================================================================
If !Empty(cDado)
	
	If (cCampo == "M->B4A_GUIREF" .or. lWeb) .And. Len(AllTrim(cDado)) >= 9
		
		//aqui primeiro procuro nas guias de internacao
		BE4->(DbSetORder(2))//BE4_FILIAL+BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT
		If BE4->(dbSeek(xFilial("BE4")+padr(cDado,18)))

			If (BE4->BE4_DATVAL + dDatRet) < dDataBase .and. Empty(BE4->BE4_DATPRO)
				if lWeb
					aadd(aRetorno,.F.)
					aadd(aRetorno,"Data de validade da Guia foi ultrapassada! ") 
						
					return .F.
				Else
					Aviso(STR0010, "Data de validade da Guia foi ultrapassada! ", {'Ok'}, 2)
					Return lRet
									
				endif                                   
 			EndIf				
			
			If lWeb .and. !empty(cRDACode)
				if !(BE4->BE4_CODRDA $ cRDACode)
					aadd(aRetorno,.F.)
					aadd(aRetorno,"A guia informada pertence a outro prestador.") //A guia informada pertence a outro prestador.
					
					return .F.
				endif					
			endif
				
			If BE4->BE4_SITUAC == '2' 
				
				If lWeb 
					aadd(aRetorno,.F.)
					aadd(aRetorno,"A guia digitada está cancelada") 			
				Else	
				
					Aviso(STR0010,"A guia digitada está cancelada",{'Ok'},2)//'Atenção' 
				EndIf

				Return lRet
				
			Else
				cConteudo 	:= BE4->BE4_CODOPE+BE4->BE4_CODLDP+BE4->BE4_CODPEG+BE4->BE4_NUMERO
				dDatAut 	:= BE4->BE4_DTDIGI //PEGO A DATA DE DIGITACAO POIS O BE4_DATPRO 'E A DATA QUE O PACIENTE FOI INTERNADO
				cUsuari 	:= BE4->(BE4_CODOPE+BE4_CODEMP+BE4_MATRIC+BE4_TIPREG+BE4_DIGITO)
				cCidPri 	:= BE4->BE4_CID
				cCidSec 	:= BE4->BE4_CIDSEC
				cCidTer 	:= BE4->BE4_CID3
				cCidQua 	:= BE4->BE4_CID4
				lRet    	:= BE4->BE4_STATUS <> "3"
				lFindBE4    := .T.
				
				//Se atendimento de Intercambio, permite prosseguir com Guia Negada
				If GetNewPar("MV_PLSUNI","1") == "1" .And. BE4->BE4_CODEMP == GetNewPar("MV_PLSGEIN","0050")   
					lRet := .T.
				EndIf
				
				If !lRet
					cMsgCri := "A guia digitada não foi autorizada" 
			
					If !lWeb
						Aviso(STR0010, cMsgCri, {'Ok'}, 2) 
					
					Else 
						aadd(aRetorno,.F.)
						aadd(aRetorno,cMsgCri) 
					EndIf
					
						Return lRet
					EndIf
				
				lRet    	:= empty(BE4->BE4_DTALTA) .or. (BE4->BE4_DTALTA > ddatabase)
				If !lRet
					cMsgCri := "Guia com data de alta já informada!"
					If !lWeb
						Aviso(STR0010, "Guia com data de alta já informada!", {'Ok'}, 2) 						
					Else
						aadd(aRetorno,.F.)
						aadd(aRetorno,"Guia com data de alta já informada!")
				EndIf
				Return lRet
			EndIf
			
			EndIf 
		Else
			BE4->( DbSetOrder(7) )//BE4_FILIAL+BE4_SENHA
			If Len(AllTrim(cDado)) <= 9 .AND. BE4->(dbSeek(xFilial("BE4")+padr(cDado,9)))

				If (BE4->BE4_DATVAL + dDatRet) < dDataBase .and. Empty(BE4->BE4_DATPRO)
					if lWeb
						aadd(aRetorno,.F.)
						aadd(aRetorno,"Data de validade da Guia foi ultrapassada! ") 
							
						return .F.
					Else
						Aviso(STR0010, "Data de validade da Guia foi ultrapassada! ", {'Ok'}, 2)
						Return lRet
										
					endif                                   
	 			EndIf				
	
				If lWeb .and. !empty(cRDACode)
					if !(BE4->BE4_CODRDA $ cRDACode)
						aadd(aRetorno,.F.)
						aadd(aRetorno,"A guia informada pertence a outro prestador.") //A guia informada pertence a outro prestador.
						
						return .F.
					endif					
				endif
			
				If BE4->BE4_CANCEL <> '1' .And. BE4->BE4_SITUAC <> '2'
					cConteudo 	:= BE4->BE4_CODOPE+BE4->BE4_CODLDP+BE4->BE4_CODPEG+BE4->BE4_NUMERO
					dDatAut 	:= BE4->BE4_DTDIGI //PEGO A DATA DE DIGITACAO POIS O BE4_DATPRO 'E A DATA QUE O PACIENTE FOI INTERNADO                                          
					cUsuari 	:= BE4->(BE4_CODOPE+BE4_CODEMP+BE4_MATRIC+BE4_TIPREG+BE4_DIGITO)
					cCidPri 	:= BE4->BE4_CID
					cCidSec 	:= BE4->BE4_CIDSEC
					cCidTer 	:= BE4->BE4_CID3
					cCidQua 	:= BE4->BE4_CID4
					lRet    	:= BE4->BE4_STATUS <> "3"
					lFindBE4    := .T.
					
					//Se atendimento de Intercambio, permite prosseguir com Guia Negada
					If GetNewPar("MV_PLSUNI","1") == "1" .And. BE4->BE4_CODEMP == GetNewPar("MV_PLSGEIN","0050")   
						lRet := .T.
					EndIf
				
					If !lRet
						cMsgCri := "Guia Não Autorizada"
						If !lWeb
							Aviso(STR0010, "Guia Não Autorizada", {'Ok'}, 2) 
							Return lRet
						EndIf
					EndIf
					
					lRet    	:= empty(BE4->BE4_DTALTA) .or. (BE4->BE4_DTALTA > ddatabase)
					If !lRet
						cMsgCri := "Guia com data de alta já informada!"
						If !lWeb
							Aviso(STR0010, "Guia com data de alta já informada!", {'Ok'}, 2) 						
						Else
							aadd(aRetorno,.F.)
							aadd(aRetorno,"Guia com data de alta já informada!")
						EndIf
						Return lRet
					EndIf
				
				Else
					Aviso(STR0010,STR0053,{'Ok'},2)//'Atenção' ## 'Guia cancelada!'
					Return lRet				
				EndIf
			Endif
		Endif
		
		//aqui primeiro procuro nas guias de sadt
		BEA->(DbSetORder(1))//BEA_FILIAL+BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT
		If !lRet .and. BEA->(dbSeek(xFilial("BEA")+padr(cDado,18)))

			If (BEA->BEA_VALSEN + dDatRet) < dDataBase
				if lWeb
					aadd(aRetorno,.F.)
					aadd(aRetorno,"Data de validade da Guia foi ultrapassada! ") //A guia informada pertence a outro prestador.
						
					return .F.
				Else
					Aviso(STR0010, "Data de validade da Guia foi ultrapassada! ", {'Ok'}, 2)
					Return lRet
									
				endif                                   
 			EndIf				
		
			If lWeb .and. !empty(cRDACode)
				if !(BEA->BEA_CODRDA $ cRDACode)
					aadd(aRetorno,.F.)
					aadd(aRetorno,"A guia informada pertence a outro prestador.") //A guia informada pertence a outro prestador.
					
					return .F.
				endif					
			endif
			
			If BEA->BEA_CANCEL <> '1'
				cConteudo	:= BEA->BEA_OPEMOV+BEA->BEA_CODLDP+BEA->BEA_CODPEG+BEA->BEA_NUMGUI  
				dDatAut 	:= BEA->BEA_DATPRO
				cUsuari 	:= BEA->(BEA_OPEMOV+BEA_CODEMP+BEA_MATRIC+BEA_TIPREG+BEA_DIGITO)
				cCidPri 	:= BEA->BEA_CID
				cCidSec 	:= BEA->BEA_CIDSEC
				cCidTer 	:= BEA->BEA_CID3
				cCidQua 	:= BEA->BEA_CID4       
				lRet    	:= BEA->BEA_STATUS <> "3"

				//Se atendimento de Intercambio, permite prosseguir com Guia Negada
				If GetNewPar("MV_PLSUNI","1") == "1" .And. BEA->BEA_CODEMP == GetNewPar("MV_PLSGEIN","0050")   
					lRet := .T.
				EndIf
				
				If !lRet
					cMsgCri := "Guia Não Autorizada"
					If !lWeb
						Aviso(STR0010, "Guia Não Autorizada!", {'Ok'}, 2) 
					Else
						aadd(aRetorno,.F.)
						aadd(aRetorno,"Guia Não Autorizada!")
					EndIf
						Return lRet
					EndIf
			Else
				If lWeb
					aadd(aRetorno,.F.)
					aadd(aRetorno,STR0053)					
			Else
				Aviso(STR0010,STR0053,{'Ok'},2)//'Atenção' ## 'Guia cancelada!'!'
				EndIf
				Return lRet
			EndIf
		Else
			BEA->( DbSetOrder(14) )//BEA_FILIAL+BEA_SENHA
			If !lRet .and. Len(AllTrim(cDado)) <= 9 .AND. BEA->(dbSeek(xFilial("BEA")+padr(cDado,9)))
				
				If lWeb .and. !empty(cRDACode)
					if !(BEA->BEA_CODRDA $ cRDACode)
						aadd(aRetorno,.F.)
						aadd(aRetorno,"A guia informada pertence a outro prestador.") //
					
						return .F.
					endif					
				endif

				If (BEA->BEA_VALSEN + dDatRet) < dDataBase
					if lWeb
						aadd(aRetorno,.F.)
						aadd(aRetorno,"Data de validade da Guia foi ultrapassada.") //A guia informada pertence a outro prestador.
							
						return .F.
					Else
						Aviso(STR0010, "Data de validade da Guia foi ultrapassada.", {'Ok'}, 2)
						Return lRet
										
					endif                                   
	 			EndIf				
					
				If BEA->BEA_CANCEL <> '1'
					cConteudo	:= BEA->BEA_OPEMOV+BEA->BEA_CODLDP+BEA->BEA_CODPEG+BEA->BEA_NUMGUI
					dDatAut 	:= BEA->BEA_DATPRO
					cUsuari 	:= BEA->(BEA_OPEMOV+BEA_CODEMP+BEA_MATRIC+BEA_TIPREG+BEA_DIGITO)
					cCidPri 	:= BEA->BEA_CID
					cCidSec 	:= BEA->BEA_CIDSEC
					cCidTer 	:= BEA->BEA_CID3
					cCidQua 	:= BEA->BEA_CID4
					lRet    	:= BEA->BEA_STATUS <> "3"
					
					//Se atendimento de Intercambio, permite prosseguir com Guia Negada
					If GetNewPar("MV_PLSUNI","1") == "1" .And. BEA->BEA_CODEMP == GetNewPar("MV_PLSGEIN","0050")   
						lRet := .T.
					EndIf
				
					If !lRet
						cMsgCri := "Guia Não Autorizada!"
						If !lWeb
							Aviso(STR0010, "Guia Não Autorizada!", {'Ok'}, 2)
							Return lRet
						Else
							aadd(aRetorno,.F.)
							aadd(aRetorno,"Guia Não Autorizada!")
						EndIf
					EndIf
				Else
					If !lWeb
					Aviso(STR0010,STR0053,{'Ok'},2)//'Atenção' ## 'Guia cancelada!'
					Else
						aadd(aRetorno,.F.)
						aadd(aRetorno,STR0053)
					EndIf
					Return lRet
				EndIf
			Endif
		Endif
		
		//Verifica se foi gerado/informado protocolo de atendimento 
		If lRet .And. GetNewPar("MV_PLRN395","0") == "1" .And. Type("cNumProto") <> "U" .And. Empty(cNumProto)  
			If lFindBE4
				cMatric := BE4->(BE4_OPEUSR+BE4_CODEMP+BE4_MATRIC+BE4_TIPREG+BE4_DIGITO)
			Else
			    cMatric := BEA->(BEA_OPEUSR+BEA_CODEMP+BEA_MATRIC+BEA_TIPREG+BEA_DIGITO)
			Endif 
				
			If GetNewPar("MV_PLSUNI","1") == "1" .And. IIF(lFindBE4,BE4->BE4_CODEMP,BEA->BEA_CODEMP) == GetNewPar("MV_PLSGEIN","0050") 
				//Quando WebService habilitado, carrega o protocolo da liberacao. Mudanca realiza pois para a Unimed Origem do 
				//Beneficiario, a Guia de Anexo "nao existe", o codigo de Transacao PTU vai estar somente na guia principal
				If GetNewPar("MV_PL395WS","0") == "1" .And. PLSALIASEX("B4J") 
					IIF(lFindBE4,cNumProto := BE4->BE4_PROATE,cNumProto := BEA->BEA_PROATE)
					M->B4A_PROATE := cNumProto 
					lInterProt := .T. 
				Else
					P773AutInc("B4A",@cNumProto,nil,.T.,.F.,nil,nil,nil,cMatric,.T.)     
					lInterProt := .T.
				EndIf
			Else
				P773AutInc("B4A",@cNumProto,nil,nil,nil,nil,nil,nil,cMatric,.T.)
			EndIf	
				
			If Empty(cNumProto) .And. !lInterProt 
				lRet := .F.
				Return lRet
			Endif	
		EndIf

		If lWeb
			IF lFindBE4 .And. BE4->BE4_CODEMP == GetNewPar("MV_PLSGEIN","0050")
				cNumProto := BE4->BE4_PROATE
			ElseIf BEA->BEA_CODEMP == GetNewPar("MV_PLSGEIN","0050")
				cNumProto := BEA->BEA_PROATE 
			Else
				cNumProto := Space(20)
			EndIf	
		Endif

		If !Empty(cConteudo) 
			//===========================================================================ÄÄÄÄ
			//³ Se existir saldo
			//===========================================================================ÄÄÄÄ
			If lRet

				BA1->(dbSetOrder(2))
				BA1->(dbSeek(xFilial("BA1")+cUsuari))

				BTS->(dbSetOrder(1))
				BTS->(dbSeek(xFilial("BTS")+BA1->BA1_MATVID))
				If !lWeb
					M->B4A_DATPRO := dDatAut
					M->B4A_USUARI := cUsuari
					M->B4A_OPEUSR := BA1->BA1_CODINT
					M->B4A_CODEMP := BA1->BA1_CODEMP
					M->B4A_MATRIC := BA1->BA1_MATRIC
					M->B4A_TIPREG := BA1->BA1_TIPREG
					M->B4A_DIGITO := BA1->BA1_DIGITO
					M->B4A_CIDPRI := cCidPri
					M->B4A_CIDSEC := cCidSec
					M->B4A_CIDTER := cCidTer
					M->B4A_CIDQUA := cCidQua
					M->B4A_PESO   := round(VAL(BTS->BTS_PESO)/1000,2)
					M->B4A_ALTURA := VAL(BTS->BTS_ALTURA)
					M->B4A_IDADE  := Calc_Idade(dDataBase,BTS->BTS_DATNAS)
					M->B4A_NOMUSR := BA1->BA1_NOMUSR
				    M->B4A_MATANT := BA1->BA1_MATANT
				    M->B4A_SEXO   := BTS->BTS_SEXO
			    	if B4A->(FieldPos("B4A_NOMSOC")) > 0
						M->B4A_NOMSOC := BA1->BA1_NOMSOC
					endIf
			    Endif
			    aRet := {'',; //[1]	
							Posicione("BA0",1,xFilial("B4A")+BA1->BA1_CODINT,"BA0_SUSEP"),; //[2]
							'',; //[3] 
							'',; //[4] 
							'',;   //[5] 
							'',; //[6]
							'',; //[7]
							'',; //[8]
							'',; //[9]
							'',; //[10]
							'',; //[11]
							'',; //[12]
							'',; //[13]
							'',; //[14]
							'',; //[15]
							dDatAut,; //[16]
							'',; //[17]
							'',; //[18]
							ctod(''),; //[19]
							ctod(''),; //[20]
							'',; //[21]
							'',; //[22]
							'',; //[23]
							'',; //[24]
							'',; //[25]
							'',; //[26]
							'',; //[27]
							'',; //[28]
							'',; //[29]
							'',; //[30]
							'',; //[31]
							'',; //[32]	 
							'',; //[33]
							'',; //[34]
							'',; //[35]   
							'',; //[36]   	
							'',; //[37]
							'',; //[38]
							cUsuari,; //[39] 
							BA1->BA1_NOMUSR,; //[40]  
							'',; //[41]
							'',; //[42]
							'',; //[43]
							'',; //[44]
							'',; //[45]
							'',; //[46]
							'',; //[47]
							'',; //[48]
							'',; //[49]
							0,; //[50]
							'',; //[51]
							'',; //[52]
							'',; //[53]
							'',; //[54]
							'',; //[55]
							'',; //[56]
							'',; //[57]
							CTOD(''	),; //[58]
							0,; //[59]
							'',; //[60]
							'',; //[61]
							'',; //[62]
							'',; //[63] 
							'',; //[64] 
							'',; //[65]
							'',; //[66]
							'',; //[67]
							'',; //[68]
							dDatAut,; //[69] 
							CTOD(''),; //[70]
							'',; //[71]
							'',; //[72]
							'',; //[73]
							'',; //[74]
							'',; //[75]   
							ctod(''),; //[76] 
							'',; //[77]  
							'',; //[78]
							'',; //[79]  
							0,; //[80]
							'',; //[81]
							alltrim(str(round(VAL(BTS->BTS_PESO)/1000,2))),;//[82]
							BTS->BTS_ALTURA,;//[83]
							alltrim(str(Calc_Idade(dDataBase,BTS->BTS_DATNAS))),;//[84]
							Iif(BTS->BTS_SEXO=='2','3','1'),;//[85] 
							'',; //[86]    
							cTod(''),; //[87]
							cTod(''),; //[88]
							cTod(''),; //[89]
							cTod(''),; //[90]
							cTod(''),; //[91]
							cTod(''),; //[92]
							cTod(''),; //[93]
							cTod(''),; //[94]
							cTod(''),; //[95]
							cTod(''),; //[96]
							cTod(''),; //[97]
							cTod(''),; //[98]
							'',; //[99]
							'',; //[100]
							'',; //[101]
							'',; //[102]
							'',; //[103]
							'',; //[104]
							'',; //[105]
							'',; //[106]
							'',; //[107]
							'',; //[108]							
							cNumProto,; //[109] 
							iif( BA1->(fieldPos("BA1_NOMSOC")) > 0, BA1->BA1_NOMSOC, "")} //[110] - nome social
		        //monto retorno
		        
				If !lWeb
					aDadUsr := PLSDADUSR(cUsuari,"1",.T.,dDataBase,nil,nil,NIL)
				Endif
			Else
				If !lWeb
					Aviso(STR0010,STR0011,{'Ok'},2)//'Atenção' ## 'Guia não encontrada!' 
				Endif
				lRet:= .F.
			Endif
		Else
			If !lWeb
				Aviso(STR0010,STR0011,{'Ok'},2)//'Atenção' ## 'Guia não encontrada!'
			Endif
			lRet:= .F.
		Endif
	Else
		If !lWeb
			Aviso(STR0010,STR0011,{'Ok'},2)//'Atenção' ## 'Guia não encontrada!'
		Endif
		lRet := .F.
	EndIf
Else
	If !lWeb
		Aviso(STR0010,STR0011,{'Ok'},2)//'Atenção' ## 'Guia não encontrada!'
	Endif
	lRet := .F.
EndIf

aadd(aRetorno,lRet)
aadd(aRetorno,cMsgCri)
aadd(aRetorno,aRet)
aadd(aRetorno,{})
aadd(aRetorno,{})

Return lRet       

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PLS09AFIL ³ Autor ³ Daher			       ³ Data ³ 12.02.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Monta o Filtro												    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLS09AFIL(cTipo)

LOCAL cFiltro := ""
//===========================================================================
//³ Filtro original
//===========================================================================
cFiltro := "B4A_FILIAL = '"+xFilial("B4A")+"' "
//===========================================================================
//³ Caso exista a necessidade de alterar o filtro
//===========================================================================
If ExistBlock("PL09AOFI")
	cFiltro := EXECBLOCK("PL09AOFI", .F. , .F. ,{cFiltro, .T. })
EndIf
//===========================================================================
//³ Fim da Funcao
//===========================================================================
Return cFiltro

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄ-ÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    PLS09AMo1 Autor ³ Daher		         	³ Data ³ 12.02.14 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄ-ÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Movimentacao														 ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function PLS09AMo1(cAlias,nReg,nOpc,cNumGui)
PRIVATE aAutForAnx 	:= {}
PRIVATE aCodCriHis 	:= {}
PRIVATE aCores 	:= {}
PRIVATE aRotina   	:= MenuDef(aCores)
PRIVATE cCadastro 	:= STR0009 //"Anexos Clinicos"
PRIVATE cNumProto   := Space(20)
PRIVATE cDesQtdAut := ''

//-------------------------------------------------------------------
//  LGPD
//-------------------------------------------------------------------
	objCENFUNLGP:useLogUser()

	oBrwPro := NIL
	
	nOpc := K_Incluir
	PLS09AMov(cAlias,nReg,nOpc,nil,'08',"",cNumGui)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄ-ÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    PLS09AMo2 Autor ³ Daher		         	³ Data ³ 12.02.14 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄ-ÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Movimentacao														 ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLS09AMo2(cAlias,nReg,nOpc,cNumGui)

PRIVATE aAutForAnx  := {}

//-------------------------------------------------------------------
//  LGPD
//-------------------------------------------------------------------
	objCENFUNLGP:useLogUser()

nOpc := K_Incluir
PLS09AMov(cAlias,nReg,nOpc,nil,'07',"",cNumGui)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄ-ÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    PLS09AMo3 Autor ³ Daher		         	³ Data ³ 12.02.14 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄ-ÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Movimentacao														 ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLS09AMo3(cAlias,nReg,nOpc,cNumGui)

PRIVATE aAutForAnx  := {}

//-------------------------------------------------------------------
//  LGPD
//-------------------------------------------------------------------
	objCENFUNLGP:useLogUser()

nOpc := K_Incluir
PLS09AMov(cAlias,nReg,nOpc,nil,'09',"",cNumGui)

Return           

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄ-ÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    PAGeObrPro Autor ³ Daher		         	³ Data ³ 12.02.14 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄ-ÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Movimentacao														 ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PAGeObrPro()
Return oBrwPro

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄ-ÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    PAGeObrC Autor ³ Daher		         	³ Data ³ 12.02.14 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄ-ÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Movimentacao														 ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PAGeObrC()    
Return oBrwCri

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄ-ÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    PAGeObEn Autor ³ Daher		         	³ Data ³ 12.02.14 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄ-ÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Movimentacao														 ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PAGeObEn()    
Return oEncAnexo
/*/

ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄ-ÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³PLS090OMov³ Autor ³ Daher		         	³ Data ³ 12.02.14 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄ-ÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Movimentacao														 ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLS09AMov(cAlias,nReg,nOpc,lAudit,cTp,cAnex,cNumGui)

LOCAL oSay02
LOCAL oSay
LOCAL I__f
LOCAL nFor
LOCAL nOpca      := 0
LOCAL aRetAux    := {}
LOCAL aCampos    := {}
LOCAL aButtons   := {}
LOCAL aRetorno   := {.T.}
LOCAL aProcAbert := {}
LOCAL aMatCom		:= {}
LOCAL bOK        := {|| nOpca := 1,If(PLA09AVLDo(@aRetorno,oEncAnexo:aGets,oEncAnexo:aTela,oBrwPro,oEncAnexo,;
														nOpc,__cTipo,oBrwCri,nil,nil,;
														aMatCom,lTemProc)[1],oDlgAnexo:End(),nOpca:=2),If(nOpca==1,oDlgAnexo:End(),.F.) }
LOCAL bCancel    := {|| oDlgAnexo:End() }
LOCAL bFilCri    := {|| }
LOCAL bFilPro    := {|| }
LOCAL nRegB4A    := Iif(B4A->(eof()),0,B4A->(Recno()))
LOCAL nOrdB4A    := B4A->(IndexOrd())
LOCAL cFaseGuia 	:= ""
LOCAL slvinclui 	:= iif(type("inclui")=="l",inclui, .t. )
LOCAL cOpeMov    := ""
LOCAL cAnoAut    := ""
LOCAL cMesAut    := ""
LOCAL cNumAut    := ""
LOCAL cSeqPF     := ""
LOCAL cChave     := B4A->(B4A_OPEMOV+B4A_ANOAUT+B4A_MESAUT+B4A_NUMAUT)
LOCAL cChGui
LOCAL aCabSint  := {}
LOCAL aDadSint  := {}
LOCAL aTrbSint  := {}
LOCAL bFilEven := {|| }
LOCAL aCabProc  := {}
LOCAL aDadProc  := {}
LOCAL aTrbProc  := {}
LOCAL lValidVis := .T.
LOCAL nX 		:= 0
Local nQtdPro   := 0
Local nValComp  := 0
local cChaveAC9 := ""
local nI 		:= 1 
LOCAL cBenef	 := ""
LOCAL cTexto	 := ""
LOCAL ctipoesp := ""
LOCAL cRda 	 	:= ""
LOCAL cLoc 	 	:= ""
LOCAL cEsp 	 	:= ""
LOCAL cCid     := ""
LOCAL cRegsol	:= ""
LOCAL cRegExe	:= ""
LOCAL cChavPac	:= ""
LOCAL I			:=0 
Local cTissVer := PLSTISSVER()
Local lTemProc := .T.
LOCAL nPosIgmSta:= 0
LOCAL nPosStatus:= 0


PRIVATE oDlgAnexo
PRIVATE oFolder
PRIVATE aMatCBkp := {}
PRIVATE _xTp	:= ''
PRIVATE nOpcPvt		:= nOpc
PRIVATE nPosQtdPro	:= 0

DEFAULT cTp		:= B4A->B4A_TIPGUI
DEFAULT lAudit	:= .F. 
DEFAULT cAnex	:=""
DEFAULT cNumGui := "" 

lTemProc := cTissVer < '3.03.00' .OR. cTp != "08" //radioterapia não tem mais procedimentos a partir da tiss 3.03.00
cNumProto   := Space(20)//Reinicia numero do protocolo
//===========================================================================
//³ Se a rotina for chamada para visualizacao pela auditoria³
//===========================================================================
If lAudit
	SX3->(DbSetOrder(2))
	SX3->(DbSeek("B4C_QTDPRO"))
	cDesQtdAut := AllTrim(X3Titulo("B4C_QTDPRO"))
EndIf

DEFINE FONT oFontAutor NAME "Arial" SIZE 000,-017 BOLD
//===========================================================================
//³ Monta aHeader e aCols Sintetico...                                       ³
//===========================================================================
aDentesFaces := {}
acabdf 		 := {}
adaddf 	     := {}
atrbdf 		 := {}
aAutFor 	 := {}
aCabCri      := {}
aDadCri	     := {}
aTrbCri      := {}
cSeq		 := ""
aDadB43 	 := {}
aCabB43 	 := {}
aTrbB43 	 := {}
//===========================================================================
//³ Busca dado do parametro...                                               ³
//===========================================================================
//³ Monta aHeader e aCols Procedimentos...                                   ³
//³ Radioterapia não tem mais procedimento a partir da TISS 3.03.01          ³
//===========================================================================
If lTemProc
	aCabProc := PLSA09AHea(cTp,__ctipo)
	aDadProc := PLSA09AClB(aCabProc)
EndIf

_xTp := If(cTp=='07','2',If(cTp=='08','1','3'))

If nOpc == 2
	If !Empty(cAnex)
		cCadastro := "Anexo Clinico - "+If(cAnex=='3',upper("Solicitação de OPME"),if(cAnex=='2',upper("Solicitação de Quimioterapia"),(cTp=='08',upper("Solicitação de Radioterapia"))))+" - Visualizar"
	Else
		cCadastro := "Anexo Clinico - "+If(cTp=='09',upper("Solicitação de OPME"),if(cTp=='07',upper("Solicitação de Quimioterapia"),(cTp=='08',upper("Solicitação de Radioterapia"))))+" - Visualizar"
	Endif	
ElseIf nOpc == 3
	cCadastro := "Anexo Clinico - "+If(cTp=='09',upper("Solicitação de OPME"),if(cTp=='07',upper("Solicitação de Quimioterapia"),(cTp=='08',upper("Solicitação de Radioterapia"))))+" - Incluir"
	//Iif (!("Incluir" $ cCadastro), cCadastro += " - "+"Incluir",'')
Elseif nOpc == 4
	cCadastro := "Anexo Clinico - "+If(cTp=='09',upper("Solicitação de OPME"),if(cTp=='07',upper("Solicitação de Quimioterapia"),(cTp=='08',upper("Solicitação de Radioterapia"))))+" - Excluir"
	nOpc := K_Excluir//corrigo o nopc pois nao tenho alterar nesta tela
Elseif nOpc == 6
	cCadastro := "Anexo Clinico - "+If(cTp=='09',upper("Solicitação de OPME"),if(cTp=='07',upper("Solicitação de Quimioterapia"),(cTp=='08',upper("Solicitação de Radioterapia"))))+" - Cancelar"
Endif


//===========================================================================
//³ Se for exclusao testa se pode ser excluida (no caso de exclusao)         ³
//===========================================================================
If nOpc == K_Excluir

	//===========================================================================ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se a Guia esta em análise pela auditoria antes da exclusão
	//===========================================================================ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !PLSVLDAUD("B4A")
		Return
	EndIf
	
	//TODO - TESTAR AQUI SE ELA JA ESTA VINCULADA A ALGUMA GUIA
		
	If B4A->B4A_CANCEL == '1'
		Aviso( STR0012,STR0013,{ 'Ok'}, 2 )//"Não foi possível a exclusão" ## "A guia ja encontra-se cancelada. Não poderá ser excluida."
		return
	Endif
EndIf
If nOpc == K_Incluir
	Inclui := .T.
Endif

If nOpc <> K_Incluir
       
	cTp  := B4A->B4A_TIPGUI
	_xTp := B4A->B4A_TIPANE
       
	Copy "B4A" TO Memory

	cOpeMov    := B4A->B4A_OPEMOV
	cAnoAut    := If(nOpc <> K_Copiar,B4A->B4A_ANOAUT,Alltrim(Str(Year(dDatabase))))
	cMesAut    := If(nOpc <> K_Copiar,B4A->B4A_MESAUT,Alltrim(Str(Month(dDatabase))))
	cNumAut    := B4A->B4A_NUMAUT
	cChave     := B4A->(B4A_OPEMOV+B4A_ANOAUT+B4A_MESAUT+B4A_NUMAUT)
       
	If nOpc ==  K_Copiar
		M->B4A_ANOAUT:=cAnoAut
		M->B4A_MESAUT:=cMesAut
	Endif
      
    If lTemProc .AND. ! PLS090MAao(cChave,"1",aCabProc,aTrbProc,aDadProc,"B4C")
		Return
	Endif

	If nOpc == K_Visualizar  .Or.  nOpc == K_Excluir
		lValidVis := .F.
	Endif

	PLSA090USR(B4A->(B4A_OPEUSR+B4A_CODEMP+B4A_MATRIC+B4A_TIPREG+B4A_DIGITO),B4A->B4A_DATPRO,'',;
		"B01",.F.,nil,nil,nil,nil,nil,nil,nil,nil,nil,;
		nil,nil,nil,lValidVis,Iif(nOpc == K_Incluir ,.T.,.F.))

   If lTemProc
	  //Variaveis de ID dos campos no browse
       nPosIgmSta	:= PLRETPOS("B4C_IMGSTA",aCabProc)
       nPosStatus	:= PLRETPOS("B4C_STATUS",aCabProc)
       nPosQtdPro	:= PLRETPOS("B4C_QTDPRO",aCabProc)

       For nFor := 1 To Len(aDadProc)
           aDadProc[nFor,nPosIgmSta] := If(aDadProc[nFor,nPosStatus]=="1","ENABLE","DISABLE")
           //Se for copia, zera os campos de quantidade para obrigar o usuario validar os procedimentos novamente
           if nOpc == K_Copiar
           		aDadProc[nFor,nPosQtdPro] := 0
           endif
       Next
       //===========================================================================
       //³ Monta as criticas relacionadas ao procedimento...                        
       //===========================================================================
		BEG->(DbCloseArea())
		Store Header "BEG" TO aCabCri For .T.
		
		BEG->(DbSetOrder(1))
		If ! BEG->(MsSeek(xFilial("BEG")+cChave))
			Store COLS Blank "BEG" TO aDadCri FROM aCabCri
		Else
			Store COLS "BEG" TO aDadCri FROM aCabCri VETTRAB aTrbCri While ;
				xFilial("BEG")+cChave == BEG->(BEG_FILIAL+BEG_OPEMOV+BEG_ANOAUT+BEG_MESAUT+BEG_NUMAUT)
		endif

		//Como a B4A não possui campos de ligação com o proc contas(B43) a regra agora é pegar a composição da guia original.
		cChavPac := B4A->B4A_GUIREF
		
		Store Header "B43" TO aCabB43 For ( alltrim(SX3->X3_CAMPO) $ PRetHeaPac() )
		B43->(DbSetOrder(2))
		If B43->(MsSeek(xFilial("B43")+cChavPac))
			Store COLS "B43" TO aDadB43 FROM aCabB43 VETTRAB aTrbB43 While B43->(B43_FILIAL+B43_OPEMOV+B43_ANOAUT+B43_MESAUT+B43_NUMAUT) == xFilial("B43")+cChavPac
		Else
			Store COLS Blank "B43" TO aDadB43 FROM aCabB43
		EndIf
		
	EndIf
	
Elseif nOpc == K_Incluir

   //===========================================================================
   //³ Valida calendario pagto...                                               ³
   //===========================================================================
	aRetAux := PLSXVLDCAL(dDataBase,PLSINTPAD(),.T.,"","")

	If ! aRetAux[1]
		Return
	Endif

	If lTemProc
		Store Header "BEG" TO aCabCri For .T.
		Store COLS Blank "BEG" TO aDadCri FROM aCabCri	       

		Store Header "B43" TO aCabB43 For ( AllTrim(SX3->X3_CAMPO) $ PRetHeaPac() )
		Store COLS Blank "B43" TO aDadB43 FROM aCabB43
		
	EndIf
	   
	Copy "B4A" TO Memory Blank

  	If !Empty(Alltrim(cNumGui))
   		
   		SX3->(DbSetOrder(2))
        SX3->(MsSeek("B4A_GUIREF"))

        M->B4A_GUIREF := cNumGui

	EndIf
   	   
	If !Empty(Alltrim(cBenef))

		SX3->(DbSetOrder(2))
		SX3->(MsSeek("B4A_USUARI"))

		M->B4A_USUARI := cBenef
		If Eval(&(" { || "+AllTrim(SX3->X3_VALID)+" }")) .And. Eval(&(" { || "+AllTrim(SX3->X3_VLDUSER)+" }"))
			RunTrigger(1)
		Endif
	EndIf

	If !Empty(cCid)

		SX3->(DbSetOrder(2))
		SX3->(MsSeek("B4A_CIDPRI"))

		M->B4A_CIDPRI := cCid

		If Eval(&(" { || "+AllTrim(SX3->X3_VALID)+" }")) .And. Eval(&(" { || "+AllTrim(SX3->X3_VLDUSER)+" }"))
			RunTrigger(1)
		Endif

	Endif

Endif

aSize := MsAdvSize()
aObjects := {}
AAdd( aObjects, { 001, Iif(GetNewPar("MV_PLSMODA","1") == "0",020,Iif(nOpc == K_Incluir ,000,020)), .T., .F.,.F. } )
AAdd( aObjects, { 001, 000, .T., .T.,.F. } )
If lTemProc
	AAdd( aObjects, { 001, 100, .T., .F.,.T. } )
EndIf

aInfo := { aSize[1],aSize[2],aSize[3],aSize[4], 5, 5 }
aPosObj := MsObjSize( aInfo, aObjects )

aPosObj[1][2]+=15
aPosObj[2][2]+=15

If lTemProc
	aPosObj[3][2]+=15
	aPosObj[3][3]-=15
EndIf


//===========================================================================
//³ Cria Dialog...                                                           ³
//===========================================================================
DEFINE MSDIALOG oDlgAnexo TITLE cCadastro FROM aSize[7],0 To aSize[6],aSize[5]  of oMainWnd PIXEL

//===========================================================================
//³ Cria Enchoice...                                                         ³
//===========================================================================
aCmp := RetCamp(cTp)

If cTp == '08'
	cTexto := STR0014 //'Procedimentos Complementares'
	STORE FIELD "B4A" TO aCampos For  (alltrim(SX3->X3_CAMPO) $ aCmp[1]+aCmp[2]) .And. cNivel >= SX3->X3_NIVEL .And. X3Uso(SX3->X3_USADO)

Elseif cTp == '07'
	cTexto := STR0015 //'Medicametos e Drogas solicitadas'
	STORE FIELD "B4A" TO aCampos For  (alltrim(SX3->X3_CAMPO) $ aCmp[1]+aCmp[2]) .And. cNivel >= SX3->X3_NIVEL .And. X3Uso(SX3->X3_USADO)

Elseif cTp == '09'
	cTexto := STR0016 //'OPME Solicitadas' 
	STORE FIELD "B4A" TO aCampos For  (alltrim(SX3->X3_CAMPO) $ aCmp[1]+aCmp[2]) .And. cNivel >= SX3->X3_NIVEL .And. X3Uso(SX3->X3_USADO)

Endif

oEncAnexo := B4A->(MSMGet():New('B4A',B4A->(Recno()),nOpc,,,,aCampos,aPosObj[2],,,,,,oDlgAnexo,,,.F.,,,Iif(nOpc<>K_Copiar,.T.,nil)))


If nOpc == K_Incluir
	M->B4A_MESPAG := aRetAux[5]
	M->B4A_ANOPAG := aRetAux[4]
Else
	If nOpc <> K_Copiar
   		//===========================================================================
		//³ Exibe say...                                                             ³
		//===========================================================================
		@ aPosObj[1,1]+6,aPosObj[1,2]+5  SAY oSay PROMPT STR0017 SIZE 220,010 OF oDlgAnexo PIXEL FONT oFontAutor //"Anexo Clínico Número  " 
		@ aPosObj[1,1]+6,aPosObj[1,2]+100 SAY oSay PROMPT TransForm(B4A->(B4A_OPEMOV+B4A_ANOAUT+B4A_MESAUT+B4A_NUMAUT),PesqPict("B4A","B4A_NUMLIB")) SIZE 220,010 OF oDlgAnexo PIXEL COLOR CLR_HRED FONT oFontAutor
	Else
		aCampoLimp:=B4A->(Dbstruct())
		For i:=1 to Len(aCampoLimp)
			If !aCampoLimp[i,1]$ ("B4A_FILIA","B4A_OPEMOV","B4A_STATUS","B4A_AUDITO")
				If Valtype((M->&(aCampoLimp[i,1])))="C"
					If Alltrim(aCampoLimp[i,1]) == "B4A_ANOPAG"
						M->&(aCampoLimp[i,1]):=Alltrim(Str(Year(dDatabase)))
					ElseIf Alltrim(aCampoLimp[i,1]) =="B4A_MESPAG"
						M->&(aCampoLimp[i,1]):=Alltrim(Str(Month(dDatabase)))
					Else
						M->&(aCampoLimp[i,1]):=Space(TamSX3(aCampoLimp[i,1])[1])
					Endif
				ElseIf  Valtype((M->&(aCampoLimp[i,1])))="N"
					M->&(aCampoLimp[i,1]):=0
				Else
					M->&(aCampoLimp[i,1]):=dDataBase
				Endif
			Endif
		next i
	
	Endif
Endif
//===========================================================================
//³ Define folder...                                                         ³
//===========================================================================
If lTemProc
	AaDd(aProcAbert,{"BMPVISUAL",{|| P090Pacote("B4C",aDadB43,aCabB43,aTrbB43)},STR0018,STR0019}) //"Visualizar procedimentos contidos no pacote"       Pacote

	oFolder 		:= TFolder():New(aPosObj[3,1],aPosObj[3,2],{cTexto,'Criticas'},{"",""},oDlgAnexo,,,,.T.,.F.,aPosObj[3,3],aPosObj[3,4])  
	oFolder:bChange := {|nFolder| oBrwPro:oBrowse:oBrowse:Refresh(), oBrwCri:ForceRefresh(oBrwPro), P09ASEQCRI() }
	//===========================================================================
	//³ Cria Eventos	                                                         ³ 
	//===========================================================================
	oBrwPro 			:= TPLSBrw():New(2,2,aPosObj[3,3]-6,aPosObj[3,4]-15,nil,  oFolder:aDialogs[1],nil,,nil,nil,nil,.T.,nil,.T.,nil,aCabProc,aDadProc,.F.,"B4C",IIf(nOpc = K_Excluir,K_Visualizar,nOpc),"Eventos da Liberação",nil,nil,nil,aTrbProc,"PlVOOOk("+cTp+")",nil,nil,{|a,b,c| PLSA090CA(a,b,c)},aProcAbert,nil,{|| PLSCANCEL(), Iif(oBrwPro:nOpcX==K_Incluir .And. FindFunction("PLSLIMSTA"),PLSLIMSTA(M->B4C_SEQUEN+M->B4C_CODPAD+M->B4C_CODPRO),nil) },{|nLinha,aHeaderEd,aColsEd,oObjetoBrw,oEncPLS| PLAMUDADES(nLinha,aHeaderEd,aColsEd,oObjetoBrw,oEncPLS)})
	oBrwPro:bLostFocus 	:= {|| P09ASEQCRI(),lRefresh := .T. }
	oBrwPro:bChange    	:= {|| Eval(oBrwPro:bLostFocus),  oBrwCri:ForceRefresh(oBrwPro) }
	
	//===========================================================================
	//³ Cria Criticas                                                            ³
	//===========================================================================
	bFilCri         := {|nLine,aCols,aHeader| aCols[nLine,PLRETPOS("BEG_SEQUEN",aHeader)] == oBrwPro:FieldGet("B4C_SEQUEN") }
	oBrwCri 		:= TPLSBrw():New(2,2,aPosObj[3,3]-6,aPosObj[3,4]-15,nil  ,oFolder:aDialogs[2],nil    ,  ,nil    ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aCabCri,aDadCri,.F.,"BEG",K_Visualizar,"Criticas da Liberação",nil,nil,nil,aTrbCri,,,bFilCri) //"Criticas da Liberação"
	oBrwCri:oPai    := oBrwPro
	oBrwCri:aOrigem := {"B4C_SEQUEN"}
	oBrwCri:aRelac  := {"BEG_SEQUEN"}
	//===========================================================================
	//³ Starta funcao padrao para montar botoes padrao...                        ³
	//===========================================================================        
EndIf

If nOpc == K_Copiar
	M->B4A_USUARI:=""
Endif

PLSA09ABot(nOpc,"B4A",oEncAnexo,oBrwPro,"B4A",{ || M->B4A_USUARI },aButtons,oFolder,oDlgAnexo,oSay02,"Autorizacao",oBrwCri) //"Autorizacao"

If existblock("PLSAADIA")
	execblock("PLSAADIA", .f. , .f. )
Endif

//===========================================================================
//³ Ativa Dialog...                                                          ³
//===========================================================================
ACTIVATE MSDIALOG oDlgAnexo ON INIT Eval( { || EnchoiceBar(oDlgAnexo,bOK,bCancel,.F.,aButtons), oEncAnexo:SetFocus() })
//===========================================================================
//³ Busca retorno contido no aRetorno...                                     ³
//===========================================================================
If nOpca == K_OK
	cOpeMov := aRetorno[2]
	cAnoAut := If(nOpc<>K_Copiar,aRetorno[3],cAnoAut)
	cMesAut := If(nOpc<>K_Copiar,aRetorno[4],cMesAut)
	cNumAut := aRetorno[5]
	lAuditoria := aRetorno[9]
   
	If nOpc == K_Copiar
		aRetorno[3]:=cAnoAut
		aRetorno[4]:=cMesAut
	Endif

	If nOpc == K_Incluir  .or. nOpc == K_Copiar
      /* Mudei este trecho de lugar, passando para dentro do PLSA09AGRV, pois lá funciona tanto no remote quanto no portal
      If lAuditoria
		
			//===========================================================================
			//³ manda para a auditoria                                                   ³
			//===========================================================================   		
	   		o790C := PLSA790C():New()
			o790C:SetAuditoria(lAuditoria,.F.,.F.,.F.,.F.,oBrwCri:aCols,oBrwCri:aHeader,__aCdCri187[1],"0","BEG",oBrwPro:aCols,oBrwPro:aHeader,"B4C", .T.)
			o790C:Destroy()
	    EndIf
      */ 
      //===========================================================================
	  //³ Conclui um protocolo                	                                   ³
  	  //===========================================================================   		 
		If GetNewPar("MV_PLRN395","0") == "1" .And. !Empty(cNumProto) .And. !(GetNewPar("MV_PL395WS","0") == "1" .And. B4A->B4A_CODEMP == GetNewPar("MV_PLSGEIN","0050") )
			P773AutCon("B4A",cNumProto,cOpeMov+cAnoAut+cMesAut+cNumAut)
		EndIf
	  
      A090FinaA(cOpeMov,cAnoAut,cMesAut,cNumAut,aRetorno,oBrwPro,lAuditoria,lTemProc)
   
	ElseIf nOpc == K_Excluir
   		
		B53->(dbSetOrder(1))
   		
		If B53->(dbSeek(xFilial("B53")+B4A->(B4A_OPEMOV+B4A_ANOAUT+B4A_MESAUT+B4A_NUMAUT)))
			B53->(RecLock("B53",.F.))
			B53->(DbDelete())
			B53->(MsUnLock())
		EndIf
	Endif
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄdbSetÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Exclui os registros no banco de conhecimento relacionados com a guia excluida //
//===========================================================================ÄÄÄÄÄ¿
If nOpca == K_OK .AND. FindFunction("PLSA092EBC")
	PLSA092EBC(cOpeMov, cAnoAut, cMesAut, cNumAut)
EndIf

//Ponto de entrada para tratamentos adicionais após inclusão da Guia de Anexo. 
if nOpca == K_OK .And. ExistBlock("PL09AFIM") .And. (nOpc == K_Excluir .Or. nOpc == K_Incluir .Or. nOpc == K_Copiar)
	ExecBlock("PL09AFIM",.F.,.F.,{cTp,nOpc,cOpeMov,cAnoAut,cMesAut,cNumAut,lAuditoria})
endif

//===========================================================================
//³ Limpa DADUSR
//===========================================================================
PLSCLEAUSR()
//===========================================================================
//³ Desativa Sets Keys...                                                    ³
//===========================================================================
SET KEY VK_F5 TO
SET KEY VK_F6 TO
SET KEY VK_F7 TO
SET KEY VK_F8 TO
SET KEY VK_F9 TO
SET KEY VK_F10 TO
SET KEY VK_F11 TO
SET KEY VK_F12 TO
//===========================================================================
//³ Refaz filtro...                                                          ³
//===========================================================================

_xNrAut		:= ''

//===========================================================================
//³ Fim da Rotina Principal...                                               ³
//===========================================================================
return
         
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Otacilio A. Junior    ³ Data ³01/06/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³	   1 - Pesquisa e Posiciona em um Banco de Dados           ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function MENUDEF(ACORES)

Local aPtoEntrada
Local cIntAnexoC    := "PLSAINTE('B4C','07', 'B4A->B4A_OPEMOV' , 'B4A->B4A_ANOAUT' , 'B4A->B4A_MESAUT' , 'B4A->B4A_NUMAUT' )"
Local cIntGuiRef    := "PLSAINTE(,'GR','Substr(B4A->B4A_GUIREF,1,4)','Substr(B4A->B4A_GUIREF,5,4)', 'Substr(B4A->B4A_GUIREF,9,2)' , 'Substr(B4A->B4A_GUIREF,11,8)')"
Local  aRotConh     := 	{{"Guia", "Pls09ABco('C')", 0, 0}, ;
		                 {"Item", "Pls09ABco('I')", 0, 0}}

Local  aRotInte     := 	{{ STR0069 ,cIntAnexoC, 0, 0}, ; // "Anexo Clínico" 
		                 { STR0070 ,cIntGuiRef, 0, 0}}   // "Guia Referência"

Private aRotina2 := {{STR0022,'PLS09AMo1',0,K_Incluir,0,.F. },;	//"Solicitação de Radioterapia" 
						{STR0023,'PLS09AMo2',0,K_Incluir,0,Nil },;	//"Solicitação de Quimioterapia" 
						{STR0024,'PLS09AMo3',0,K_Incluir,0,Nil }}		//"Solicitação de OPME"  

Private aRotina := {	{STR0025,'AxPesqui'		    ,0 ,K_Pesquisar	    ,0 ,.F. },;	//"Pesquisar" 
						{STR0026,'PLS09AMov'		,0 ,K_Visualizar	,0 ,Nil },; //"Visualizar" 
						{STR0027,aRotina2			,0 ,K_Incluir		,0 ,Nil },;	//"Incluir" 
						{STR0028,'PLS09AMov'		,0 ,K_Excluir		,0 ,Nil },;	//"Excluir"
						{STR0029,'PLS09AIm2'		,0 ,K_Imprimir	    ,0 ,Nil },;	//"Imp.Guia" 
						{STR0030,'PLS09AMov'		,0 ,K_Copiar		,0 ,Nil },;	//"Copiar" 
						{STR0031,'PLSA0A2CAN()'	    ,0 ,K_Visualizar	,0 ,Nil },;	//"Cancelar Anexo"  
						{STR0032,aRotConh			,0 ,K_BCOCON		,0 ,Nil },;	//"Conhecimento"  
						{STR0071, aRotInte		    ,0 ,K_Incluir		,0 ,Nil }}  // "Interação"    

//Protocolo de Atendimento
If GetNewPar("MV_PLRN395","0") == "1"
	AaDd( aRotina,{ STR0056 ,'PL9AInfPro()' , 0 , K_Alterar , 0 , Nil} ) //"Informar Protoc."
EndIf

//===========================================================================
//³ Para ponto de entrada													 ³
//===========================================================================
If ExistBlock("PLS09AM1")
	aPtoEntrada := ExecBlock("PLS09AM1",.F.,.F.)
	AaDd( aRotina,{ aPtoEntrada[1] ,aPtoEntrada[2] , 0 , K_Imprimir , 0 , Nil} )
Endif
//===========================================================================
//³ Para ponto de entrada													 ³
//===========================================================================
If ExistBlock("PLS09AM2")
	aPtoEntrada := ExecBlock("PLS09AM2",.F.,.F.)
	AaDd( aRotina,{ aPtoEntrada[1] ,aPtoEntrada[2] , 0 , K_Imprimir , 0 , Nil} )
Endif
//===========================================================================
//³ Para ponto de entrada													 ³
//===========================================================================
If ExistBlock("PLS09AM3")
	aPtoEntrada := ExecBlock("PLS09AM3",.F.,.F.)
	AaDd( aRotina,{ aPtoEntrada[1] ,aPtoEntrada[2] , 0 , K_Imprimir , 0 , Nil} )
Endif

If ExistBlock("PLS09ACR")
	aCores := ExecBlock( "PLS09ACR",.F.,.F., aCores )
Else
	   aCores 	:= 	{	{ "B4A->B4A_TIPGUI=='09'", 'BR_BRANCO' },;
		{ "B4A->B4A_TIPGUI=='07'", 'BR_AMARELO' },;
		{ "B4A->B4A_TIPGUI=='08'", 'BR_CINZA'    } }

       aCdCores := {	{ 'BR_CINZA'	, STR0022},; //"Solicitação de Radioterapia"
					 	{ 'BR_AMARELO', STR0023},; //'Solicitação Quimioterapia' 
					 	{ 'BR_BRANCO'	, STR0024} } //'Solicitação OPME' 

	Aadd(aRotina, { 'Legenda'    	 , "PLS09ALOD"		, 0 , K_Incluir     })
Endif

Return(aRotina)
                                              
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PLS09Alod ³ Autor ³ Daher			        ³ Data ³ 12.02.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Legenda													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLS09Alod()

BrwLegenda(ccadastro,'Legenda',acdcores)

Return  
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    PLSA09HCHe ³ Autor ³ Daher			        ³ Data ³ 12.02.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Legenda													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA09HCHe() 

LOCAL aCab1 := {}                                                 

Store Header "BEG" TO aCab1 For .T.

Return  aCab1  

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    PLSA09HClB ³ Autor ³ Daher			        ³ Data ³ 12.02.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Legenda													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/                       
Function PLSA09HClB(aCab2)     
 
LOCAL aCab1 := {} 

Store COLS Blank "BEG" TO aCab1 FROM aCab2

Return aCab1
   
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    PLSA09AHea ³ Autor ³ Daher			        ³ Data ³ 12.02.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ 															  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA09AHea(cTipo,cTpTipo,nOpc)
LOCAL nPos     	:= 0
LOCAL cCampos  	:= PLSA09AFld(cTipo,cTpTipo)
LOCAL aCabProc 	:= {}

DEFAULT cTpTipo := __cTipo
DEFAULT nOpc	:= K_Visualizar

Store Header "B4C" TO aCabProc For ( alltrim(SX3->X3_CAMPO) $ cCampos )

Return(aCabProc)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    RetCamp ³ Autor ³ Daher			        ³ Data ³ 12.02.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ 															  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RetCamp(cTp)                             
LOCAL cCampOb := ''
LOCAL cCamNOb := ''   
LOCAL cTipGui := ''    

cTipGui := cTp
	
BCM->(DbSetOrder(1))	
If BCM->(MsSeek(xFilial('BCM')+PlsIntPad()+cTipGui))
	While !BCM->(Eof()) .and. BCM->BCM_TIPGUI == cTipGui		
		cCampOb += BCM->BCM_CAMPO
		BCM->(DbSkip())
	Enddo
Endif
If GetNewPar("MV_PLRN395","0") == "1"
	cCamNOb += ",B4A_PROATE"	
EndIf		
If ExistBlock("PLS09ACP")
	aCampOb := ExecBlock("PLS09ACP",.F.,.F.,{cCampOb,cTp,cCamNOb})
	aCampOb := aCampOb[1]
	cCamNOb := aCampOb[2]
Endif

Return {cCampOb,cCamNOb}

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PLSA09AFLD³ Autor ³ Daher		           ³ Data ³ 13.06.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Monta campos padroes para a getDados do Procedimentos...   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA09AFld(cTipo,cTpTipo)   

//CAMPOS GERAIS QUE SEMPRE DEVEM APARECER
LOCAL cCampos := "B4C_CODPAD,B4C_SEQUEN,B4C_NIVEL ,B4C_CODPRO,B4C_DESPRO,B4C_QTD   ,B4C_STATUS,"
      cCampos += "B4C_QTDPRO,B4C_IMGSTA,B4C_NIVAUT,B4C_CHVNIV,B4C_NIVCRI,B4C_VLPGMA,B4C_AUDITO,B4C_VIA   ,"
      cCampos += "B4C_PERVIA,B4C_PROCCI,B4C_CDPDRC,B4C_PROREL,B4C_PRPRRL,B4C_VLCOMP,B4C_LIBESP,B4C_PEREVC,
      cCampos += "B4C_VLRAPR,B4C_BLOCPA,B4C_BLOPAG,B4C_DNIVCR,B4C_DNIVAU,B4C_SOLREV,B4C_COMUNI,B4C_NRAOPE, "
      cCampos += "B4C_GUIACO,B4C_QUACOB,B4C_VALORI,B4C_CODAUD,B4C_SALDO ,B4C_QTDSOL"
      
DEFAULT cTipo   := ""        
DEFAULT cTpTipo := __cTipo

If cTipo == '08'//RADIO
	cCampos += 'B4C_DATPRO'
ElseIf cTipo == '07' //QUIMIO
	cCampos += 'B4C_VIAADM,B4C_FREQUE,B4C_DATPRO,B4C_UNMED'
ElseIf cTipo == '09' //OPME
	cCampos += 'B4C_OPCAO,B4C_VLRUNT,B4C_VLRUNA,B4C_REGANV,B4C_AUTFUN,B4C_REFMAF'
	If B4C->( FieldPos("B4C_ORDEDI") ) > 0
		cCampos += ',B4C_ORDEDI'
	EndIf
Endif

If B4C->( FieldPos("B4C_NRTROL") ) > 0 .And. B4C->( FieldPos("B4C_NRAOPE") ) > 0  .And. B4C->( FieldPos("B4C_COMUNI") ) > 0
	cCampos += ',B4C_NRTROL,B4C_NRAOPE,B4C_COMUNI'	
EndIf     
     
If  ExistBlock("PL09AFL1")
  cCampos := ExecBlock("PL09AFL1",.F.,.F.,{cCampos})
EndIf

Return(cCampos)      

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PLSA09ACLB³ Autor ³ Daher		            ³ Data ³ 13.06.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Monta aCols Blank padrao...                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA09AClB(aCabProc)

LOCAL aDadProc := {}

Store COLS Blank "B4C" TO aDadProc FROM aCabProc

Return(aDadProc)                     

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³P09ASEQCRI³ Autor ³ Daher		            ³ Data ³ 13.06.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cria Sequencia											  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/                                                                            
Function P09ASEQCRI(nTipo)
LOCAL cRet := "001"
DEFAULT nTipo := 0

If nTipo == 0
	If ValType(oBrwPro) == "O"
		cRet := oBrwPro:FieldGet("B4C_SEQUEN")
	EndIf
Else
	If BEG->( FieldPos("BEG_SEQCRI") ) > 0
		If ValType(oBrwCri) == "O"
			If !(oBrwCri:aCols[Len(oBrwCri:aCols),Len(oBrwCri:aHeader)+1])
				cRet := PLSINCRE("BEG_SEQCRI",oBrwCri)
			EndIf
		Else
			cRet := PLSINCRE("BEG_SEQCRI")
		Endif
	Endif
Endif

Return(cRet)
                                                                                                
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PLSA09ASEQ³ Autor ³ Daher		           ³ Data ³ 12.02.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cria Sequencia											  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/                                                                            
Function PLSA09ASEQ

LOCAL cRet
If ValType(oBrwPro) == "O"
   If oBrwPro:aCols[Len(oBrwPro:aCols),Len(oBrwPro:aHeader)+1]
	   cRet := Soma1(oBrwPro:FieldGet("B4C_SEQUEN"))
   Else
	   cRet := PLSINCRE("B4C_SEQUEN",oBrwPro)
   EndIf	   
Else
   cRet := PLSINCRE("B4C_SEQUEN")
Endif              

Return(cRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PLA09AUSU³ Autor ³ Daher		           ³ Data ³ 12.02.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ 															  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/                                                                            
Function PLA09AUSU     

LOCAL lRet := .F.     

If Empty(M->B4A_USUARI)
     return .T. 
Endif          
If PLSA090USR(M->B4A_USUARI,M->B4A_DATSOL,NIL,"B4A")
	//M->B4A_PESO   := round(VAL(BTS->BTS_PESO)/1000,2)
	M->B4A_ALTURA := VAL(BTS->BTS_ALTURA)
	M->B4A_IDADE  := Calc_Idade(dDataBase,BTS->BTS_DATNAS)
	lRet := .T.
Endif  

RETURN lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PLSA090BOT³ Autor ³ Daher		            ³ Data ³ 13.06.12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Monta botoes e keys...                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA09ABot(nOpc,cAliasEnc,oEncAnexo,oBrwPro,cAliasPro,bMatUsr,aButtons,oFolder,oDlgAnexo,oSay02,cDescri,oBrwCri,lBtnOn)
LOCAL lAnt
LOCAL bBotao01   := {|| A09ALimpa(cAliasEnc,oEncAnexo,oBrwPro,"B4A",,,.T.)}
LOCAL bBotao02 := {|| PLPOSFIN(Eval(bMatUsr),.T.,.T.) } 
LOCAL bBotao03 := {|| PLHISMOV(Eval(bMatUsr)) }
LOCAL bBotao04 := {|| PLAltCli(Eval(bMatUsr), .T.) }
LOCAL bBotao05 := {|| BA1->(DbSetOrder(2)), BA1->(MsSeek(xFilial("BA1")+&("M->"+cAliasEnc+"_USUARI"))), If(BA1->(Found()),PLSVLRCOB(,,.T.),Help("",1,"PLSA090USR")) }
LOCAL bBotao06 := {|| lAnt := Inclui,Inclui := .F., BA1->(DbSetOrder(2)), BA1->(MsSeek(xFilial("BA1")+&("M->"+cAliasEnc+"_USUARI"))), If(BA1->(Found()),PLSA260MOV("BA1",BA1->(RECNO()),K_Visualizar),Help("",1,"PLSA090USR")), Inclui := lAnt}
LOCAL bBotao07 := {|| BA1->(DbSetOrder(2)), BA1->(MsSeek(xFilial("BA1")+&("M->"+cAliasEnc+"_USUARI"))), If(BA1->(Found()),PLSBENEF("BA1",BA1->(RECNO()),K_Visualizar),Help("",1,"PLSA090USR")) }
LOCAL bBotao08   := {|| PLSA090ACO(cAliasEnc,oEncAnexo,oBrwCri,oBrwPro) }
LOCAL bBotao09   := {|| PLSA090CPR(cAliasEnc,oEncAnexo,oBrwCri,__cTipo,oBrwPro) }
LOCAL bBotao10 := {|| BA3->(DbSetOrder(1)), BA3->(MsSeek(xFilial("BA3")+Subs(&("M->"+cAliasEnc+"_USUARI"),1,14))), If(BA3->(Found()),ExeQuest(),Help("",1,"PLSA090QUE")) }
LOCAL bBotao13 := {|| PLSA096(SUBSTR(&("M->"+cAliasEnc+"_USUARI"),1,4),SUBSTR(&("M->"+cAliasEnc+"_USUARI"),5,4),SUBSTR(&("M->"+cAliasEnc+"_USUARI"),9,6),SUBSTR(&("M->"+cAliasEnc+"_USUARI"),15,2),SUBSTR(&("M->"+cAliasEnc+"_USUARI"),17,1)) }
LOCAL bBotao11 := {|| PLSMSGCA(Eval(bMatUsr)) }
LOCAL bBotao17   := {|| PLSA09AMTC(cAliasEnc,oEncAnexo,oBrwCri,__cTipo,oBrwPro, ,B4A->(RECNO()), "B4A", Inclui) } 
LOCAL aDadRda  := PLSGETRDA()   
LOCAL aPTBot	  := {.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.} 
LOCAL oBotao
LOCAL aPtoEntrB1
LOCAL aPtoEntrB2
LOCAL cCodCri    
LOCAL J
LOCAL nTamArray

DEFAULT cDescri  := __cDescri  
DEFAULT lBtnOn  := .F.
//===========================================================================
//³ Verifica																 ³
//===========================================================================
If nOpc == K_Incluir
	aadd(aButtons,{"S4WB004N",bBotao01,"Limpar Tela - <F5>","Limpa"})
	SetKey(VK_F5,bBotao01)
Endif
//===========================================================================
//³ Ponto de entrada para desabilitar BOTOES PARA um grupo de operadores	 ³
//===========================================================================
If ExistBlock("PLSAUTOP")
	aPTBot := ExecBlock("PLSAUTOP",.F.,.F.,{"PLSA090"})
	nTamArray:= Len(aPTBot)
	If nTamArray < 16
		For j:=(nTamArray+1) to 16
			aadd(aPTBot,.T.)
		Next
	EndIf
EndIf
//===========================================================================
//³ Botoes																	 ³
//===========================================================================
If aPTBot[1]
	aadd(aButtons,{"SALARIOS",bBotao02,STR0033,STR0034}) //"Posicao Financeira - <F6>" ## "Financ"  
	SetKey(VK_F6,bBotao02)
EndIf
	
If aPTBot[2]
	aadd(aButtons,{"POSCLI",bBotao04,STR0035,STR0036}) //"Alterar Dados do Cliente - <F8>" ## "Cliente"  
	SetKey(VK_F8,bBotao04)
EndIf
	
If aPTBot[3]
	aadd(aButtons,{"PLNPROP",bBotao05,STR0037,STR0038})//"Composicao de Cobranca - <F9>" ## "Cobranca"  
	SetKey(VK_F9,bBotao05)
EndIf

If aPTBot[4]
	aadd(aButtons,{"GROUP",bBotao06,STR0039,STR0040}) //"Dados da Familia - <F10>" ## "Familia" 
	SetKey(VK_F10,bBotao06)
EndIf

If aPTBot[5]
	aadd(aButtons,{"RELATORIO",bBotao03,STR0041,STR0042})//"Historico de Movimentacao - <F7>" ## "Historico"
	SetKey(VK_F7,bBotao03)
EndIf

If aPTBot[6]
	aadd(aButtons,{"RESPONSA",bBotao07,STR0043,"Benef."})//"Dados da vida do beneficiario - <F11>" ## "Benef."  
	SetKey(VK_F11,bBotao07)
EndIf

If aPTBot[7]
	aadd(aButtons,{"S4WB007N",{ || A090INTGER(cAliasEnc) },"Usuarios de Outros Intercambios","Usuarios de intercâmbio"})
EndIf

If aPTBot[8]
	aadd(aButtons,{"S4WB009N",{ || A09AMovPOS() },"Consultar Movimentacoes Negadas em POS/Internet/Outros","Mov.Neg."})
EndIf
   
//===========================================================================
//³ Botao Hist Criticas Forcadas											 ³
//===========================================================================
If nOpc == K_Visualizar
	aadd(aButtons,{"S4WB010N",{ || PLS090FOR("B4A","B4C",oBrwPro) },"Hist. Criticas Forçadas","Crit. Forçadas"})
Endif

//************************ 
If aPTBot[17]
	aadd(aButtons,{"S4WB009N",bBotao17,"Motivo Neg. Auditoria","Motivo Neg. Auditoria"}) //"Consultar Movimentacoes Negadas em POS/Internet/Outros"###"Mov.Neg."
EndIf
//************************

//===========================================================================
//³ Monta outros botoes de apoio...                                          ³
//===========================================================================
If aPTBot[11]
	@ 030,002 BTNBMP oBotao RESOURCE "VERNOTA" SIZE 030 ,030 OF oDlgAnexo PIXEL MESSAGE "Grupo de carencia" ACTION Eval(bBotao11) 
Endif
If aPTBot[12]
	@ 065,002 BTNBMP oBotao RESOURCE "NOTE" SIZE 030 ,030 OF oDlgAnexo PIXEL MESSAGE "Grupos de Cobertura" ACTION PLSRTGCUSR(&("M->"+cAliasEnc+"_USUARI")) 
Endif
If aPTBot[13]
	@ 100,002 BTNBMP oBotao RESOURCE "RELATORIO" SIZE 030 ,030 OF oDlgAnexo PIXEL MESSAGE "Visualizar Entrevista Qualificada do Usuario" ACTION Eval(bBotao10) 
Endif

nLin := 135
If FindFunction("PLSC005")
	If aPTBot[15]
		nLin += 35
	    @ nLin,002 BTNBMP oBotao RESOURCE "S4WB016N" SIZE 030 ,030 OF oDlgAnexo PIXEL MESSAGE "Consultar Cobertura/Carencia" ACTION Eval( {||  BA1->(DbSetOrder(2)),;
			PLSC005()} )
	Endif
Endif
If FindFunction("PL169HIST")
	If aPTBot[16]
		nLin += 35
   	 	@ nLin,002 BTNBMP oBotao RESOURCE "HISTORIC" SIZE 030 ,030 OF oDlgAnexo PIXEL MESSAGE "Historico Transferencia" ACTION PL169HIST() 
	Endif
Endif

If GetNewPar("MV_PLRN395","0") == "1"
	If nOpc == K_Visualizar 
   		cNumProto := B4A->B4A_PROATE
	EndIf
	nLin += 35
	@ nLin,002 BTNBMP oBotao RESOURCE "USER" SIZE 030 ,030 OF oDlgAnexo PIXEL MESSAGE STR0057 ACTION P773AutInc("B4A",@cNumProto,NIL,NIL,.T.,nOpc)  //"Protocolo de Atendimento"
EndIf

If ExistBlock("PLS09AB1")
	aPtoEntrB1 := ExecBlock("PLS09AB1",.F.,.F.)
	nLin += 35
   @ nLin,002 BTNBMP oBotao RESOURCE aPtoEntrB1[1] SIZE 030 ,030 OF oDlgAnexo PIXEL MESSAGE aPtoEntrB1[2] ACTION Eval(aPtoEntrB1[3])
Endif

If ExistBlock("PLS09AB2")
	aPtoEntrB2 := ExecBlock("PLS09AB2",.F.,.F.)
	nLin += 35
   @ nLin,002 BTNBMP oBotao RESOURCE aPtoEntrB2[1] SIZE 030 ,030 OF oDlgAnexo PIXEL MESSAGE aPtoEntrB2[2] ACTION Eval(aPtoEntrB2[3])
Endif

If ExistBlock("PLS09AB3") .and. nOpc == K_Incluir
	cCodCri := ExecBlock("PLS09AB3",.F.,.F.)
	BCT->( DbSetOrder(1) ) //BCT_FILIAL + BCT_CODOPE + BCT_PROPRI + BCT_CODGLO
	If BCT->( MsSeek( xFilial( 'BCT' )+PLSINTPAD()+cCodCri )  )// Trocar o 701 pelo codigo da sua critica
		nLin += 35
	   @ nLin,002 BTNBMP oBotao RESOURCE "AFASTAMENTO" SIZE 030 ,030 OF oDlgAnexo PIXEL MESSAGE "Negar Autorização" ACTION PL090CRINE(cCodCri)
	EndIf
Endif

If SuperGetMv("MV_BIOCONF",,.F.) .And. ("PLSA315" $ UPPER( Alltrim( Funname() ) ) .OR. SuperGetMv("MV_BIOATEN",,.F.) )
	nLin += 35
	@ nLin,002 BTNBMP oBotao RESOURCE "OBJETIVO" SIZE 030 ,030 OF oDlgAnexo PIXEL MESSAGE "Biometria" ACTION PL090BIO(cAliasEnc,.F.) 
EndIf

Return
                                       
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    A09AMovPOS Autor ³ Daher	                ³ Data ³ 13.06.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ 															  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/                                                                                                    
Static Function A09AMovPOS()

LOCAL cOldCad := cCadastro

PLSA086()
cCadastro := cOldCad

Return                

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ A09ALIMPA³ Autor ³ Tulio Cesar           ³ Data ³ 13.02.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ 															³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A09ALimpa(cAlias,oEnchoice,oBrowse,cAliasGetd,lItens,lUsr,lPerg,cAliCri,oGet01,cGet01)
//===========================================================================
//³ Define variaveis...                                                      ³
//===========================================================================
LOCAL cField
LOCAL cCpoUsr  := cAlias+"_USUARI,"+cAlias+"_MATANT,"+cAlias+"_NOMUSR,"+cAlias+"_TIPUSR"

DEFAULT lItens := .T.
DEFAULT lUsr   := .T.
DEFAULT lPerg  := .F.	
DEFAULT cAliCri := "BEG"
DEFAULT oGet01  := nil
DEFAULT cGet01  := ""
//===========================================================================
//³ Para escolha do usuario se limpa a guia ou somente os eventos e criticas ³
//===========================================================================
If lPerg
	If  Aviso(	"Atenção", "Deseja limpar os campos de todos os folders?",{ 'Sim', 'Nao'}, 2 ) == 1
		lPerg := .F.
	Else
		lPerg := .T.
	EndIf
EndIf
If !lPerg
	//===========================================================================
	//³ Em todos os campo da enchoice zera conteudo...                           ³
	//===========================================================================
	SX3->(DbSetOrder(1))
	IF SX3->(MsSeek(cAlias))
		While ! SX3->(Eof()) .And. SX3->X3_ARQUIVO == cAlias
	         
			cField := AllTrim(SX3->X3_CAMPO)
	         
			If ! (cField $ cAlias+"_ANOPAG,"+cAlias+"_MESPAG")
				If     cField $ cCpoUsr
					If lUsr
						M->&(cField) := CriaVar(cField)
					Endif
				Else
					M->&(cField) := CriaVar(cField)
				Endif
			Endif
	
			SX3->(DbSkip())
		Enddo
	Endif
EndIF
//===========================================================================
//³ Limpa itens...                                                           ³
//===========================================================================
If lItens
	A090Clr(cAliCri,oBrwCri)
	A090Clr(cAliasGetd,oBrowse)
	If !Empty(cGet01)
		A090Clr(cGet01,oGet01)
	Endif
Endif
//===========================================================================
//³ Atualiza Enchoice...                                                     ³
//===========================================================================
lRefresh := .T.
oEnchoice:oBox:Refresh()
oEnchoice:oBox:SetFocus()

Return
    
/*/
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    Pls09ABco Autor ³ Daher	                ³ Data ³ 12.02.14 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Banco de conhecimento dos itens                            ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Sintaxe   ³ PlsBcoCon()                                                ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³ Uso      ³ Advanced Protheus                                          ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³ Alteracoes desde sua construcao inicial.                              ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³ Data     ³ BOPS ³ Programador ³ Breve Descricao                       ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³          ³      ³             ³                                       ³±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Pls09ABco(cOp)                 

Local aArea		:= GetArea()
Local aAreaB4A	:= B4A->(GetArea())
Local aRotBack  := aRotina
Local cQuery	:= ""
Local cIndex	:= ""
LOCAL cChaveInt  	:= B4A->(B4A_OPEMOV+B4A_ANOAUT+B4A_MESAUT+B4A_NUMAUT)
LOCAL cChaveAC9 := B4A->B4A_FILIAL+cChaveInt

Default cOp		:= "I" // C = Anexo vinculado ao cabeçalho  I = Anexo vinculado ao item

aRotina := {{'Conhecimento','MsDocument',0,3},{"Inclusão Rápida",'PLSDOcs',0,3}} //"Conhecimento"
B4A->( DbSetOrder(1) ) //B4A_FILIAL + B4A_OPEMOV + B4A_ANOAUT + B4A_MESAUT + B4A_NUMAUT + DTOS(B4A_DATPRO) + B4A_HORPRO
B4A->( MsSeek( xFilial("B4A") + cChaveInt ) )

If cOp == "I" // inclusão nos itens
	DbSelectArea("B4C")
	cIndex := CriaTrab(NIL,.F.)
	cQuery := "B4C_FILIAL == '" + xFilial("B4C") + "' "
	cQuery += " .And. B4C_OPEMOV == '" + B4A->B4A_OPEMOV + "'"
	cQuery += " .And. B4C_ANOAUT == '" + B4A->B4A_ANOAUT + "'"
	cQuery += " .And. B4C_MESAUT == '" + B4A->B4A_MESAUT + "'"
	cQuery += " .And. B4C_NUMAUT == '" + B4A->B4A_NUMAUT + "'"
	IndRegua("B4C",cIndex,B4C->(IndexKey()),,cQuery)
	If B4C->(!Eof())
		MaWndBrowse(0,0,300,600,"Retorno de Doctos. de Saida","B4C",,aRotina,,,,.T.,,,,,,.F.) //"Retorno de Doctos. de Saida"
	EndIf
	
	If PLSALIASEX("B53")

		AC9->(DbSetOrder(2))//AC9_FILIAL, AC9_ENTIDA, AC9_FILENT, AC9_CODENT, AC9_CODOBJ, R_E_C_N_O_, D_E_L_E_T_
	
		If AC9->(dbSeek( xFilial("AC9") + "B4C" +xfilial('B4C')+cChaveAC9))
			dbSelectArea("B53")
			If B53->(dbSeek(xFilial("B53")+cChaveInt))
				If B53->B53_BANCON != '1'
					B53->(Reclock("B53",.F.))
					B53->B53_BANCON := '1'
					B53->(MsUnlock())
				EndIf
			EndIf
		else
			dbSelectArea("B53")
			If B53->(dbSeek(xFilial("B53")+cChaveInt))
				If B53->B53_BANCON != '0'
					B53->(Reclock("B53",.F.))
					B53->B53_BANCON := '0'
					B53->(MsUnlock())
				EndIf
			EndIf
		EndIf
	EndIf

	RetIndex( "B4C" )
	dbClearFilter()
	FErase( cIndex+OrdBagExt() )
Else
	MsDocument( "B4A", B4A->( RecNo() ), 2 )
	PLSATUB53(cChaveAC9, cChaveInt, "B4A")	
EndIf

aRotina := aRotBack

dbSelectArea("B4C")
dbSetOrder(1)

B4A->( RestArea(aAreaB4A) )
RestArea(aArea)

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSPESAUT ³ Autor ³ Daher			   ³ Data ³ 13.02.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Pesquisa generica de Procedimentos ...                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Altera‡„o                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Tulio Cesar ³27.05.02³ xxxx ³ Acertos/Melhorias...                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSPESAUT(cNroGui)

	Static objCENFUNLGP := CENFUNLGP():New()

LOCAL nReg          := 0
LOCAL nLin       	:= 1
LOCAL nOpca      	:= 0
LOCAL nSaldo		:= 0
LOCAL nOrdem     	:= 1
LOCAL cChave     	:= Space(40)
LOCAL cTipoPes   	:= ""
LOCAL cCabec		:= ""
LOCAL cSQL 			:= ""
LOCAL cSetFocus 	:= ""
LOCAL cTipoGuia 	:= 'Iif(aBrowPro[oBrowPro:nAt, 12] == "1", "BEA", "BE4")'
LOCAL oDlgPesPro    := NIL
LOCAL oTipoPes		:= NIL
LOCAL oSayPro       := NIL
LOCAL oBrowPro		:= NIL
LOCAL oGetChave		:= NIL
LOCAL oChkChk		:= NIL
LOCAL oPanel 		:= NIL
LOCAL oFont			:= NIL
LOCAL aBrowPro   	:= {}
LOCAL aVetPad    	:= { {"","",0,"","","","","","","","", ""} }
LOCAL bRefresh   	:= { || If(!Empty(cChave),PLSAPAUTPQ(AllTrim(cChave),Subs(cTipoPes,1,1),lChkChk,aBrowPro,aVetPad,oBrowPro,cVarRead),.T.), If( Empty(aBrowPro[1,1]) .And. !Empty(cChave),.F.,.T. )  }
LOCAL cValid     	:= "{|| Eval(bRefresh) }"
LOCAL bOK        	:= { || If(!Empty(cChave),(nLin := oBrowPro:nAt,nOpca := 1,lOk:=.T.,oDlgPesPro:End()),Help("",1,"PLSMCON")) }
LOCAL bCanc      	:= { || nOpca := 3,oDlgPesPro:End() }
LOCAL aTipoPes   	:= {}
LOCAL lChkChk    	:= .F.
LOCAL lRet		 	:= .F.
LOCAL aButtons   	:= {} 
LOCAL dDatAnalise	:= dDataBase
LOCAL dDatPro		:= dDataBase
LOCAL aDadUsr		:= PLSGETUSR()      
LOCAL aItensPac     := {} 
LOCAL cVarRead		:= ReadVar()

PRIVATE aOpcoes   	:= {}
PRIVATE cCadastro 	:= ""             

If ExistBlock("PLSPESPR")
	lRet := ExecBlock("PLSPESPR",.F.,.F.,{})
Else
	aBrowPro := aClone(aVetPad)
	aTipoPes := {'1-Nome Beneficiario','2-Nro da Liberação','3-Matricula','4-Nome Social'}

	//===========================================================================
	//³ Define dialogo...                                                        ³
	//===========================================================================
	DEFINE MSDIALOG oDlgPesPro TITLE "Pesquisa de Liberações" FROM 008.2,000 TO 030,ndColFin OF GetWndDefault()
	//===========================================================================
	//³ Monta objeto que recebera o a chave de pesquisa  ...                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oGetChave := TGet():New(040,085,{ | U | IF( PCOUNT() == 0, cChave, cChave := U ) },oDlgPesPro,210,008 ,"@!",&cValid,nil,nil,nil,nil,nil,.T.,nil,.F.,nil,.F.,nil,nil,.F.,nil,nil,cChave)
	@ 040,008 COMBOBOX oTipoPes  Var cTipoPes ITEMS aTipoPes SIZE 070,010 OF oDlgPesPro PIXEL COLOR CLR_HBLUE
 	@ 040,315 CHECKBOX oChkChk   Var lChkChk PROMPT "Pesquisar Palavra Chave" PIXEL SIZE 080, 010 OF oDlgPesPro
 	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta Browse...                                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oBrowPro := TcBrowse():New( 060, 008, 390, 075,,,, oDlgPesPro,,,,,,,,,,,, .F.,, .T.,, .F., )
	
	oBrowPro:AddColumn(TcColumn():New("",nil,;
		nil,nil,nil,nil,015,.T.,.F.,nil,nil,nil,.F.,nil))
	oBrowPro:ACOLUMNS[1]:BDATA := { || aBrowPro[oBrowPro:nAt,4] }
	
	oBrowPro:AddColumn(TcColumn():New("Nro Liberação",nil,;
		nil,nil,nil,nil,060,.F.,.F.,nil,nil,nil,.F.,nil))
	oBrowPro:ACOLUMNS[2]:BDATA := { || aBrowPro[oBrowPro:nAt,5] }
	
	oBrowPro:AddColumn(TcColumn():New("Mat. Beneficiario",nil,;
		nil,nil,nil,nil,060,.F.,.F.,nil,nil,nil,.F.,nil))
	oBrowPro:ACOLUMNS[3]:BDATA := { || aBrowPro[oBrowPro:nAt,1] }
	
	oBrowPro:AddColumn(TcColumn():New("Mat. Antiga",nil,;
		nil,nil,nil,nil,060,.F.,.F.,nil,nil,nil,.F.,nil))
	oBrowPro:ACOLUMNS[4]:BDATA := { || aBrowPro[oBrowPro:nAt,10] }
	
	oBrowPro:AddColumn(TcColumn():New("Nome Beneficiario",nil,;
		nil,nil,nil,nil,090,.F.,.F.,nil,nil,nil,.F.,nil))
	oBrowPro:ACOLUMNS[5]:BDATA := { || aBrowPro[oBrowPro:nAt,2] }
	
	oBrowPro:AddColumn(TcColumn():New("Nome Social",nil,;
		nil,nil,nil,nil,090,.F.,.F.,nil,nil,nil,.F.,nil))
	oBrowPro:ACOLUMNS[6]:BDATA := { || aBrowPro[oBrowPro:nAt,11] }

	oBrowPro:AddColumn(TcColumn():New("Plano",nil,;
		nil,nil,nil,nil,020,.F.,.F.,nil,nil,nil,.F.,nil))
	oBrowPro:ACOLUMNS[7]:BDATA := { || aBrowPro[oBrowPro:nAt,8] }
	
	oBrowPro:AddColumn(TcColumn():New("Descrição",nil,;
		nil,nil,nil,nil,090,.F.,.F.,nil,nil,nil,.F.,nil))
	oBrowPro:ACOLUMNS[8]:BDATA := { || aBrowPro[oBrowPro:nAt,7] }
	
	oBrowPro:AddColumn(TcColumn():New("Nome RDA",nil,;
		nil,nil,nil,nil,090,.F.,.F.,nil,nil,nil,.F.,nil))
	oBrowPro:ACOLUMNS[9]:BDATA := { || aBrowPro[oBrowPro:nAt,6] }
	
	oBrowPro:AddColumn(TcColumn():New("Codigo RDA",nil,;
		nil,nil,nil,nil,020,.F.,.F.,nil,nil,nil,.F.,nil))
	oBrowPro:ACOLUMNS[10]:BDATA := { || aBrowPro[oBrowPro:nAt,9] }

//-------------------------------------------------------------------
//  LGPD
//-------------------------------------------------------------------
	if objCENFUNLGP:isLGPDAt()
		aCampos := {.F.,;
					"BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT",;
					"BEA_OPEUSR+BEA_CODEMP+BEA_MATRIC+BEA_TIPREG+BEA_DIGITO",;
					"BA1_MATANT",;
					"BEA_NOMUSR",;
					"BA1_NOMSOC",;
					"BA3_CODPLA",;
					"BI3_DESCRI",;
					"BEA_NOMRDA",;
					"BEA_CODRDA"}
		aBls := objCENFUNLGP:getTcBrw(aCampos)

		oBrowPro:aObfuscatedCols := aBls
	endif
	
	oBrowPro:SetArray(aBrowPro)
	oBrowPro:BLDBLCLICK := bOK
	oTipoPes:bLostFocus := { || cSetFocus := "{ || oGetChave:Refresh(),oGetChave:SetFocus(),.T.}", &(cSetFocus) }

	//Inclui botão visualizar
	oPanel := TPanel():New(30,0,'', oDlgPesPro,, .T., .T.,, ,315,20,.T.,.T. ) 
	oFont := TFont():New('Times New Roman',,-18,.T.)

	@ 007,013 BITMAP oBmp RESNAME "BR_AMARELO" SIZE 020,020 OF oPanel PIXEL NOBORDER WHEN .F. 
	@ 007,025 Say    oSay PROMPT  'Internação' SIZE 100,010 OF oPanel PIXEL
	@ 007,120 BITMAP oBmp RESNAME "BR_VERDE"   SIZE 020,020 OF oPanel PIXEL NOBORDER WHEN .F. 
	@ 007,130 Say    oSay PROMPT  'Serviços'   SIZE 100,010 OF oPanel PIXEL 
	@ 003, 335 BUTTON STR0026 SIZE 060, 015 ACTION PL09PGRef(&(cTipoGuia), &("oBrowPro:aArray[oBrowPro:nAt, 5]")) OF oPanel PIXEL //Visualizar
	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ativa o Dialogo...                                                       ³
	//===========================================================================
	ACTIVATE MSDIALOG oDlgPesPro ON INIT Eval({ || oGetChave:SetFocus(), EnChoiceBar(oDlgPesPro,bOK,bCanc,.F.,aButtons), oPanel:Align:=CONTROL_ALIGN_BOTTOM }) CENTERED
	//===========================================================================Ä
	//³ OK
	//===========================================================================Ä
	If nOpca == K_OK
		M->B4A_GUIREF := strtran(strtran(aBrowPro[nLin,5],'-',''),'.','')
		lRet := .T.
	EndIf
EndIf
//===========================================================================Ä
//³Retorno da Funcao...                                                     
//===========================================================================Ä
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSAPAUTPQ ³ Autor ³ Daher			   ³ Data ³ 12.02.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Pesquisa o liberacoes na base de dados ...              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Altera‡„o                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Tulio Cesar ³27.05.02³ xxxx ³ Acertos/Melhorias...                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PLSAPAUTPQ(cChave,cTipoPes,lChkChk,aBrowPro,aVetPad,oBrowPro,cVarRead)
LOCAL aArea   	:= GetArea()
LOCAL cSQL      := ""                          
LOCAL cRetBEA 	:= ""
LOCAL cRetBE4 	:= ""
LOCAL cExp		:= Iif(AllTrim(TcGetDB()) $ "DB2/ORACLE/POSTGRES","||","+")
LOCAL nRecno    := 0
LOCAL cNomUsr	:= ""
LOCAL cNomRda	:= ""
LOCAL cCodRda	:= ""
LOCAL cNomSoc   := ""
LOCAL cCodPla   := ""
LOCAL cMatAnt   := ""
LOCAL cNomePla  := ""
DEFAULT cVarRead := ""

If '"' $ cChave .Or. "'" $ cChave
	Aviso( "Caracter Invalido","Existem caracteres invalidos em sua pesquisa.",{ 'Ok'}, 2 )
  Return(.F.)
EndIf
//===========================================================================Ä
//³ Nome das tabelas
//===========================================================================Ä
cRetBEA := BEA->(RetSQLName("BEA"))
cRetBE4 := BE4->(RetSQLName("BE4"))
//===========================================================================
//³ Limpa resultado...                                                       ³
//===========================================================================
aBrowPro := {}
//===========================================================================Ä
//³ Veio de uma liberacao ou foi informado participacao
//===========================================================================Ä

	//===========================================================================Ä
	//³ BR8
	//===========================================================================Ä
	cSQL := "SELECT '1' TIPO,BEA_OPEMOV" + cExp + "BEA_ANOAUT" + cExp + "BEA_MESAUT" + cExp + "BEA_NUMAUT NUMLIB,BEA_NOMUSR NOMEUSR,BEA_OPEUSR" + cExp + "BEA_CODEMP" + cExp + "BEA_MATRIC" + cExp + "BEA_TIPREG" + cExp + "BEA_DIGITO MATRICULA, "
	cSQL += " BEA_NOMRDA NOMRED,BEA_CODRDA CODRDA"
	cSQL += ","+cRetBEA+".R_E_C_N_O_ AS RECNES "	
	cSQL += "  FROM " + cRetBEA
	
	If cTipoPes == '4'
		cSQL += " INNER JOIN "+RetSqlName("BA1")+" AS BA1 ON BA1.BA1_FILIAL = BEA_FILIAL AND BA1.BA1_MATVID = BEA_MATVID AND BA1.D_E_L_E_T_ = ' ' AND BA1.BA1_NOMSOC LIKE '"+cChave+"%' "
	EndIf

	cSQL += " WHERE BEA_FILIAL = '"+xFilial("BEA")+"' " 

	If cTipoPes == '2' //numero
    	cSql += " AND BEA_OPEMOV = '"+substr(cChave,1,4)+"' "
		cSql += " AND BEA_ANOAUT = '"+substr(cChave,5,4)+"' "
		cSql += " AND BEA_MESAUT = '"+substr(cChave,9,2)+"' "
		cSql += " AND BEA_NUMAUT = '"+substr(cChave,11,8)+"' "
	ElseIf cTipoPes == '1' //nome     
		cSql += " AND BEA_NOMUSR LIKE  '"+cChave+"%' "
	ElseIf cTipoPes == '3' //matricula
		cSql += " AND BEA_OPEUSR = '"+substr(cChave,1,4)+"' "
		cSql += " AND BEA_CODEMP = '"+substr(cChave,5,4)+"' "
		cSql += " AND BEA_MATRIC = '"+substr(cChave,9,6)+"' "
		cSql += " AND BEA_TIPREG = '"+substr(cChave,15,2)+"' "
	EndIf

	cSQL += "   AND BEA_TIPGUI <> '03' "
	cSQL += "   AND BEA_CANCEL <> '1' "
	cSQL += "   AND "+cRetBEA+".D_E_L_E_T_ = ' ' "
		
	cSQL += " UNION "

	cSQL += "SELECT '2' TIPO,BE4_CODOPE" + cExp + "BE4_ANOINT" + cExp + "BE4_MESINT" + cExp + "BE4_NUMINT NUMLIB,BE4_NOMUSR NOMEUSR,BE4_OPEUSR" + cExp + "BE4_CODEMP" + cExp + "BE4_MATRIC" + cExp + "BE4_TIPREG" + cExp + "BE4_DIGITO MATRICULA, "
	cSQL += " BE4_NOMRDA NOMRED,BE4_CODRDA CODRDA"
	cSQL += ","+cRetBE4+".R_E_C_N_O_ AS RECNES "
	cSQL += "  FROM " + cRetBE4

	If cTipoPes == '4'
		cSQL += " INNER JOIN "+RetSqlName("BA1")+" AS BA1 ON BA1.BA1_FILIAL = BE4_FILIAL AND BA1.BA1_MATVID = BE4_MATVID AND BA1.D_E_L_E_T_ = ' ' AND BA1.BA1_NOMSOC LIKE  '"+cChave+"%' "
	EndIf

	cSQL += " WHERE BE4_FILIAL = '"+xFilial("BE4")+"' " 
		
  	If cTipoPes == '2' //numero
    	cSql += " AND BE4_CODOPE = '"+substr(cChave,1,4)+"' "
		cSql += " AND BE4_ANOINT = '"+substr(cChave,5,4)+"' "
		cSql += " AND BE4_MESINT = '"+substr(cChave,9,2)+"' "
		cSql += " AND BE4_NUMINT = '"+substr(cChave,11,8)+"' "
	ElseIf cTipoPes == '1' //nome     
		cSql += " AND BE4_NOMUSR LIKE '"+cChave+"%'"
	ElseIf cTipoPes == '3' //matricula
		cSql += " AND BE4_OPEUSR = '"+substr(cChave,1,4)+"' "
		cSql += " AND BE4_CODEMP = '"+substr(cChave,5,4)+"' "
		cSql += " AND BE4_MATRIC = '"+substr(cChave,9,6)+"' "
		cSql += " AND BE4_TIPREG = '"+substr(cChave,15,2)+"' "
	Endif

	cSQL += "   AND BE4_CANCEL <> '1' "
	cSQL += "   AND BE4_SITUAC <> '2' "
	cSQL += "   AND "+cRetBE4+".D_E_L_E_T_ = ' ' "
	cSQL += "   ORDER BY NUMLIB "
//===========================================================================Ä
//³ executa a query
//=============================='=============================================Ä
cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TrbPes",.F.,.T.)
//===========================================================================Ä
//³ While na area de trabalho
//===========================================================================Ä
TrbPes->( DbGoTop() )
While !TrbPes->( Eof() )
	cTp     := TrbPes->TIPO
	cNumLib := transform(TrbPes->NUMLIB,"@R !!!!.!!!!.!!.!!!!!!!!")
	cMatric := transform(TrbPes->MATRICULA,"@R !!!!.!!!!.!!!!!!-!!")
	nRecno  := TrbPes->RECNES
	cNomUsr	:= TrbPes->NOMEUSR
	cNomRda	:= TrbPes->NOMRED
	cCodRda	:= TrbPes->CODRDA
	cSQL := " SELECT BA1_MATANT,BA1_CODPLA,BA3_CODPLA,BA1_NOMSOC FROM "+RetSqlName('BA1')+' BA1,'+RetSqlName('BA3')+' BA3'
	cSQL += " WHERE BA1.BA1_FILIAL =  '"+xFilial('BA1')+"'"
	cSQL += " AND BA1.BA1_CODINT = '"+substr(TrbPes->MATRICULA,1,4)+"' "
	cSQL += " AND BA1.BA1_CODEMP = '"+substr(TrbPes->MATRICULA,5,4)+"' "
	cSQL += " AND BA1.BA1_MATRIC = '"+substr(TrbPes->MATRICULA,9,6)+"' "
	cSQL += " AND BA1.BA1_TIPREG = '"+substr(TrbPes->MATRICULA,15,2)+"' "
	cSQL += " AND BA1.D_E_L_E_T_ = ' ' "
	cSQL += " AND BA3.BA3_FILIAL = BA1.BA1_FILIAL "
	cSQL += " AND BA3.BA3_CODINT = BA1.BA1_CODINT "
	cSQL += " AND BA3.BA3_CODEMP = BA1.BA1_CODEMP "
	cSQL += " AND BA3.BA3_MATRIC = BA1.BA1_MATRIC "
	cSQL += " AND BA3.D_E_L_E_T_ = ' ' "

	// Codigo do Plano.
	cSQL := ChangeQuery(cSQL)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TrbPes1",.F.,.T.)
	
	cCodPla := IIF(EMPTY(TrbPes1->BA1_CODPLA),TrbPes1->BA3_CODPLA,TrbPes1->BA1_CODPLA)
	cMatAnt := TrbPes1->BA1_MATANT
	If BI3->( dbSeek(xFilial("BI3") + substr(TrbPes->MATRICULA,1,4) + cCodPla) )
		cNomePla := BI3->BI3_DESCRI
	Else
		cNomePla := " "
	Endif
	cNomSoc := TrbPes1->BA1_NOMSOC

	TrbPes1->( DbCloseArea() )
	TrbPes->( AaDd( aBrowPro,{ cMatric,cNomUsr,nRecno,If(cTp=='1',"BR_VERDE","BR_AMARELO"),cNumLib,cNomRda,cNomePla,cCodPla,cCodRda,cMatAnt,cNomSoc, cTp } ) )
	TrbPes->( DbSkip() )
EndDo
//===========================================================================Ä
//³ fecha area
//===========================================================================Ä
TrbPes->( DbCloseArea() )
RestArea(aArea)
//===========================================================================
//³ Testa resultado da pesquisa...                                           ³
//===========================================================================
If Len(aBrowPro) == 0
	aBrowPro := aClone(aVetPad)
EndIf
//===========================================================================
//³ Atualiza browse...                                                       ³
//===========================================================================
oBrowPro:nAt := 1 // Configuro nAt para um 1 pois estava ocorrendo erro de "array out of bound" qdo se fazia
                  // uma pesquisa mais abrangante e depois uma uma nova pesquisa menos abrangente
                  // Exemplo:
                  // 1a. Pesquisa: "A" - Tecle <END> para ir ao final e retorne ate a primeira linha do browse
                  // (via seta para cima ou clique na primeira linha)
                  // 2a. Pesquisa: "AV" - Ocorria o erro
oBrowPro:SetArray(aBrowPro)
oBrowPro:Refresh()
oBrowPro:SetFocus()
//===========================================================================
//³ Fim da Rotina...                                                         ³
//===========================================================================
Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PlVOOOk ³ Autor ³ Daher			   ³ Data ³ 12.02.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Pesquisa o liberacoes na base de dados ...              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Altera‡„o                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Tulio Cesar ³27.05.02³ xxxx ³ Acertos/Melhorias...                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PlVOOOk(cTp)
LOCAL lRet 	  := .T.
LOCAL cCodOpmGen := GetNewPar("MV_PLOPMPT","") 

If cTp == 9 .And. GetNewPar("MV_PLSUNI","1") == "1" .And. Alltrim(M->B4C_CODPRO) == Alltrim(cCodOpmGen) .And. ;
	(Empty(M->B4C_REGANV) .Or. Empty(M->B4C_REFMAF) )
	MsgInfo("Para OPME Genérico, é necessário informar o Código ANVISA do Mat/Med e Referência do Material no Fabricante.")
  lRet := .F.
EndIf

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºProgram   PLAMUDADES ³Daherº Date ³  04/29/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Troca da Descricao do campo B4C_QTDPRO			         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PLAMUDADES(nLinha,aHeaderEd,aColsEd,oObjetoBrw,oEncPLS)
Local nI		:= 0
Local nX 		:= 0     
Local nInd		:= 0
Local aTela 	:= aClone(oEncPLS:aTela)
Local aFields	:= {}
private cDesQtdAut 

For nI := 1 To Len(aTela)
 	//na versao 11 mudou... agora tem que mexer tambem no aentryctrls
	aFields	:= aTela[nI]
	For nX := 1 To Len(aFields)
		If AllTrim(cDesQtdAut) == AllTrim(aFields[nX])
			For nInd := 1 To Len(oEncPls:AENTRYCTRLS)
				If ALLTRIM(oEncPls:AENTRYCTRLS[nInd]:cReadVar) == "M->B4C_QTDPRO"
					If _xTp == '3'
						oEncPls:aentryctrls[nInd]:oparent:ctitle := strtran(oEncPls:aentryctrls[nInd]:oparent:ctitle,AllTrim(cDesQtdAut),Alltrim('Qtd.Aut.'))
					Elseif _xTp == '2'
						oEncPls:aentryctrls[nInd]:oparent:ctitle := strtran(oEncPls:aentryctrls[nInd]:oparent:ctitle,AllTrim(cDesQtdAut),Alltrim('Doses'))
					Elseif _xTp == '1'
						oEncPls:aentryctrls[nInd]:oparent:ctitle := strtran(oEncPls:aentryctrls[nInd]:oparent:ctitle,AllTrim(cDesQtdAut),Alltrim('Qtd.'))
					Endif
				Endif
			Next
		Endif
	Next nX
Next

//Se for copia, zera os campos de quantidade para obrigar o usuario validar os procedimentos novamente
if nOpcPvt == K_Copiar
	M->B4C_QTDPRO := 0
endif

oBrwCri:ForceRefresh(oBrwCri)
	
Return .T.
                

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PLSA090CA³ Autor ³ Daher		            ³ Data ³ 13.02.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ 													          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA090CA(nLinha,aHeaderEd,aColsEd)
LOCAL nPos := PLRETPOS("B4C_IMGSTA",aHeaderEd,.F.)

If nPos > 0
   aColsEd[nLinha,nPos] := If(M->B4C_STATUS=="1","ENABLE","DISABLE")
Endif
//===========================================================================
//³ Bkp do browse criticas													 ³
//===========================================================================
aMatCBkp := aClone(oBrwCri:aCols)
//===========================================================================
//³ Fim da rotina															 ³
//===========================================================================
Return
        
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSCANCEL ³ Autor ³ Daher			    ³ Data ³ 13.02.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Se cancelar na EditRecord retorna para o original		  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Static Function PLSCANCEL()

Local ni:=0
//===========================================================================ÄÄÄÄÄÄÄÄ¿
//³ Se cancelado retorna original													 |
//===========================================================================ÄÄÄÄÄÄÄÄÙ
If ValType(aMatCBkp) <> 'U'
	If Len(aMatCBkp)>0
		oBrwCri:aCols := aClone(aMatCBkp)
		oBrwCri:oBrowse:oBrowse:nAt := Len(aMatCBkp)
	Else
		oBrwCri:aCols:={Array(Len(oBrwCri:AHEADER)+1)}
		

		For nI := 1 To Len(oBrwCri:AHEADER)
			cX3Campo := AlLTrim( oBrwCri:AHEADER[nI][2] )
			oBrwCri:aCols[1,nI]:=CriaVar( cX3Campo, .T. )
		Next
		
		oBrwCri:aCols[1,(Len(oBrwCri:AHEADER)+1)]:=.F.
		oBrwCri:OBROWSE:ForceRefresh()
		
	Endif
EndIf	
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSA090Vld ³ Autor ³ Daher	            ³ Data ³ 13.02.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao que confirma uma autorizacao retornando o seu numero³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                               
Function PLA09AVLDo(aRetorno,aGets,aTela,oBrwPro,oEncAnexo,;
						nOpc,cTipo,oBrwCri,cNaoUsado,lNMudFase,;
						aMatCom,lTemProc)
LOCAL nI
LOCAL nFor    
LOCAL cCmpStat  
LOCAL lUmVld	 	:= .F.
LOCAL lPossuiIt		:= .F.
LOCAL lTemProc		:= oBrwPro != Nil
    
LOCAL aCodProcs		:={}
LOCAL aChaveGen  	:= {}
LOCAL aDadB4A    	:= {}
LOCAL aDadUsr    	:= PLSGETUSR()
LOCAL cDescCmpo   	:= "B4C_QTDPRO"
LOCAL cCodUsr 		:= RetCodUsr()
    

DEFAULT aMatCom	:= {}
DEFAULT cNaoUsado:= ""    
DEFAULT lTemProc	:= .T. 

//  GUSTAVO BARCELOS - 04/09/2017 - Incluída chamada de método para Limpar Filtro do Browse de Críticas antes da gravação.
If lTemProc
	oBrwCri:EndFilter()
EndIf

//===========================================================================
//³ Parametro utilizado para verifica campos Obrigatorios na função (TudoOK)												  
//===========================================================================
If lTemProc
oBrwPro:cCmpStat    := "B4C_IMGSTA"
EndIf

//===========================================================================ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se foi informado algum procedimento												   ³
//===========================================================================ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lTemProc
	For nI := 1 To Len(oBrwPro:aCols)
	
		If !oBrwPro:aCols[nI,Len(oBrwPro:aHeader)+1]
			lUmVld := .T.
		EndIf
	Next nI
Else
	lUmVld := .T.
EndIf
//===========================================================================ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Exibe msg se nao for informado																   ³
//===========================================================================ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lUmVld
	Aviso(	"Atencao",; 				//"Atencao"
	"Nenhum procedimento informado!",; 				//"Nenhum procedimento informado!"
	{ "ok" }, 2 ) 		//"ok"
	Return(.F.)
EndIf
//===========================================================================
//³ Nao e preciso validacao para visualizacao								 ³
//===========================================================================
If nOpc == K_Visualizar
	aRetorno := {.T.,B4A->B4A_OPEMOV,B4A->B4A_ANOAUT,B4A->B4A_MESAUT,B4A->B4A_NUMAUT,.T.,"","",.F.,""}
	Return(aRetorno)
Endif
//===========================================================================
//³ Caso que pode acontecer da guia com ano e mes em branco...               ³
//===========================================================================
If Empty(M->B4A_ANOPAG) .Or. Empty(M->B4A_MESPAG)
	MsgStop("Ano ou Mes de pagamento em branco. Esta guia nao pode ser gravada.")
	aRetorno := {.F.,'',.T.,"","",.F.,""}
	Return(aRetorno)
Endif
//===========================================================================
//³ Verifica Campos Obrigatorios					                             ³
//===========================================================================
If  !Obrigatorio(oEncAnexo:aGets,oEncAnexo:aTela) .Or. (lTemProc .AND. !oBrwPro:TudoOK(,cDescCmpo)) 
	aRetorno := {.F.,'',.T.,"","",.F.,""}
	Return(aRetorno)
Endif

//===========================================================================
//³ ERRO CONTROLADO...               										 ³
//===========================================================================
If nOpc <> K_Excluir .And. Len(aDadUsr) > 2 .and. AllTrim(M->B4A_MATANT) <> AllTrim(aDadUsr[3])
	MsgStop("Matricula antiga contida na [MEMORIA] diferente da contida no [ADADUSR]. Contate o suporte.")
	aRetorno := {.F.,'',.T.,"","",.F.,""}
	Return(aRetorno)
Endif
//===========================================================================
//³Verifica se existem itens ativos na getdados³
//===========================================================================
If lTemProc
	For nFor := 1 To Len(oBrwPro:aCols)
		
		if !oBrwPro:aCols[nFor,Len(oBrwPro:aHeader)+1]
			lPossuiIt := .T.
			Exit
		Endif
	Next
Else
	lPossuiIt := .T.
EndIf
//===========================================================================
//³lPossuiIt								   ³
//===========================================================================
If !lPossuiIt
	Help(" ",1,"OBRIGAT")
	aRetorno := {.F.,'',.T.,"","",.F.,""}
	Return(aRetorno)
Endif
  
//===========================================================================
//³ Analiso procedimentos incompativeis e cids incompativeis...              ³
//===========================================================================
If lTemProc
	For nFor := 1 To Len(oBrwPro:aCols)
	
		If (oBrwPro:FieldGet("B4C_STATUS",nFor) == "1" .And. !oBrwPro:aCols[nFor,Len(oBrwPro:aHeader)+1]) .or.  (cTipo =='2' .And. oBrwPro:FieldGet("B4C_AUDITO",nFor) == "1" .And. !oBrwPro:aCols[nFor,Len(oBrwPro:aHeader)+1])// quando se tratar de auditoria teremos que analisar os procedimento incompativeis
	        
			AaDd(aCodProcs,{oBrwPro:FieldGet("B4C_CODPAD",nFor),;
				oBrwPro:FieldGet("B4C_CODPRO",nFor),;
				"",;
				"",;
				"",;
				oBrwPro:FieldGet("B4C_QTDPRO",nFor),;
				"",;
				oBrwPro:FieldGet("B4C_SEQUEN",nFor)})
	                                              
		Endif
		
	Next
	
EndIf

If PLSPOSGLO(PLSINTPAD(),__aCdCri197[1],__aCdCri197[2],'1','1')
	aOldCodCri  := PLLimpCCri(.F.)
	If aOldCodCri == nil
		aOldCodCri  := {}
	Endif
	PLLimpCCri(.T.)
	
	If ( nOpc == K_Incluir ) .And. Len(aCodProcs) > 0
		For ni:=1 to len(aCodProcs)
			aRetFun := PLSVLDPRI(M->B4A_CIDPRI,"1",aCodProcs,aDadUsr,M->B4A_DATPRO,,,,aCodProcs[ni,1],aCodProcs[ni,2],aCodProcs[ni,8]) // CHAMANDO O PROCEDIMENTOS INCOMPATIVEIS
		   
			If ! aRetFun[1]
		
				lForcar := BCT->(Posicione("BCT",1,xFilial("BCT")+PlsIntPad()+aRetFun[2][1][1],"BCT_PERFOR")) == "1"
				lForcou := PLSMOVCRI("2",{},aRetFun[2],lForcar)
		
				If  lForcar .And. lForcou
					aadd(aAutFor,{.T.,"","","","","","",0,BCS->(cCodUsr),Date(),Time()})
					Exit
				Else
					aRetorno := {.F.,'',.T.,"","",.F.,""}
					Return(aRetorno)
				Endif
			Endif
		Next ni
	Endif
	PLLimpCCri(.F.,.T.,aOldCodCri)
Endif

//===========================================================================
//³ Ponto de entrada referente ao BOPS 114367/116047						 
//===========================================================================
If ExistBlock("PLS09AOK")
	If !ExecBlock("PLS09AOK",.F.,.F., {nOpc,oBrwPro})
		aRetorno := {.F.,'',.T.,"","",.F.,""}
		Return(aRetorno)
	Endif
Endif
aRetAux := PLSXVLDCAL(dDataBase,PLSINTPAD(),.T.,"","")

aadd(aDadB4A,{"B4A_MATANT",BA1->BA1_MATANT })
aadd(aDadB4A,{"B4A_OPEUSR",BA1->BA1_CODINT })
aadd(aDadB4A,{"B4A_CODEMP",BA1->BA1_CODEMP })
aadd(aDadB4A,{"B4A_CONEMP",BA1->BA1_CONEMP })
aadd(aDadB4A,{"B4A_SUBCON",BA1->BA1_SUBCON })
aadd(aDadB4A,{"B4A_VERCON",BA1->BA1_VERCON })
aadd(aDadB4A,{"B4A_VERSUB",BA1->BA1_VERSUB })
aadd(aDadB4A,{"B4A_MATRIC",BA1->BA1_MATRIC })
aadd(aDadB4A,{"B4A_TIPREG",BA1->BA1_TIPREG })
aadd(aDadB4A,{"B4A_DIGITO",BA1->BA1_DIGITO })
aadd(aDadB4A,{"B4A_NOMUSR",BA1->BA1_NOMUSR })
aadd(aDadB4A,{"B4A_CANCEL",'0' })
aadd(aDadB4A,{"B4A_TIPANE",_xTp})
aadd(aDadB4A,{"B4A_TIPGUI",If(_xTp=='2','07',If(_xTp=='1','08','09'))})
aadd(aDadB4A,{"B4A_ANOPAG",aRetAux[4] })
aadd(aDadB4A,{"B4A_MESPAG",aRetAux[5] })
aadd(aDadB4A,{"B4A_GUIREF",M->B4A_GUIREF }) //Adicionando a guia de referência já no array dos dados para poder buscar o status da guia pai na gravação quando for radioterapia

aRetorno := PLSA09AGRV(nOpc,PlsIntPad(),'B4C','B4A','BEG',;
						  aDadB4A,IIf(lTemProc,oBrwPro:aHeader,{}),IIf(lTemProc,oBrwPro:aCols,{}),IIf(lTemProc,oBrwPro:aVetTrab,{}),IIf(lTemProc,oBrwCri:aHeader,{}),;
						  IIf(lTemProc,oBrwCri:aCols,{}),IIf(lTemProc,oBrwCri:aVetTrab,{}),If(_xTp=='2','07',If(_xTp=='1','08','09')),dDataBase,aRetAux[4],;
						  aRetAux[5],aChaveGen,lTemProc)

Return(aRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSA09AGRV ³ Autor ³ Daher	            ³ Data ³ 13.02.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Gravacao dos Anexos										  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                               
Function PLSA09AGRV(nOpc,cOpeMov,cAliasIte,cAliasCab,cAliasCri,;
						aDadCab,aHeadIten,aColsIten,aVetTrIten,aCabCri,;
						aDadCri,aTrbCri,cTp,dData,cAnoPag,;
						cMesPag,aChaveGen,lTemProc,lGuiAudit) 
LOCAL nFor   	 := 0 
LOCAL nPos   	 := 0
LOCAL nPos2  	 := 0
LOCAL nPos01 	 := 0
LOCAL nPos02 	 := 0            
LOCAL nItensAut  := 0
LOCAL nItensNeg  := 0
LOCAL nAuditAut  := 0           
LOCAL nAuditNeg  := 0
LOCAL lVisGui	 := B4A->( FieldPos("B4A_VISGUI") ) > 0
LOCAL lAuditoria := .F.
LOCAL lGerSenha  := .F.
LOCAL lPortal    := If(FunName()="RPC",.t.,.f.)
LOCAL cRetOpe    := alltrim(PLRETOPE())
LOCAL lRet       := .T.
LOCAL cSenhaPLS  := '' 
LOCAL cStatus    := ''                       
LOCAL cTpGrv	 := '1' //1=Remote Protheus;2=Web;3=POS;4=Importacao Manual
LOCAL bOpeMov    	:= { || IF(nOpc == K_Incluir,PLSINTPAD(),&(cAliasCab+"->"+cAliasCab+"_OPEMOV")   ) }
LOCAL bAnoAut    	:= { || IF(nOpc == K_Incluir,cAnoPag ,&(cAliasCab+"->"+cAliasCab+"_ANOAUT") ) }
LOCAL bMesAut    	:= { || IF(nOpc == K_Incluir,cMesPag ,&(cAliasCab+"->"+cAliasCab+"_MESAUT")) }
LOCAL bNumAut    	:= { || IF(nOpc == K_Incluir,PLNUMAUT(Eval(bOpeMov),Eval(bAnoAut),Eval(bMesAut)),&(cAliasCab+"->"+cAliasCab+"_NUMAUT")) }
LOCAL aCpoChv    	:= { "B4A_FILIAL","B4A_OPEMOV","B4A_ANOAUT","B4A_MESAUT","B4A_NUMAUT",'B4A_STATUS'}
LOCAL ccTissVer	    := PLSTISSVER()
LOCAL cGuiRef		:= ''
LOCAL cMesRef		:= ''
LOCAL cAnoRef		:= ''
Local cStatus		:= ''
Local cQuery		:= ''
Local cStGuiaPai  := ''

DEFAULT lTemProc    := Iif (!Empty(lTemProc), lTemProc, (ccTissVer < '3.03.00' .OR. cTp != "08")) //radioterapia não tem mais procedimentos a partir da tiss 3.03.00
DEFAULT lGuiAudit   := .F. //Se a guia está sendo gerada pela rotina de inclusão de procedimentos pela auditoria 

aStrucCab := &(cAliasCab+"->(DbStruct())")

//cTp -> 1 - Radio, 2 - Quimio, 3- OPME
BA0->(DbSetOrder(1))
If BA0->(MsSeek(xFilial('BA0')+cOpeMov))
	If cTp == '08'
		lGerSenha := BA0->BA0_SENRAD == '1'
	ElseIf cTp == '07'
		lGerSenha := BA0->BA0_SENQUI == '1'
	Elseif cTp == '09'
		lGerSenha := BA0->BA0_SENOPM == '1'
	Endif
Endif

If nOpc <> K_Excluir
	nPos   := PLRETPOS(cAliasIte+"_STATUS",aHeadIten,.F.)
	nPos2  := PLRETPOS(cAliasIte+"_AUDITO",aHeadIten,.F.)
	nPos01 := PLRETPOS(cAliasIte+"_SEQUEN",aHeadIten,.F.)
	nPos02 := PLRETPOS(cAliasIte+"_QTDPRO",aHeadIten,.F.)
	
	//Verifica itens autorizados e negados (se for radioterapia, aColsIten vem vazio pois não tem procedimento)
	For nFor := 1 To Len(aColsIten)
		If ! aColsITEn[nFor,Len(aHeadIten)+1]
			If nPos > 0
				If  aColsITEn[nFor,nPos] == "1"
					nItensAut ++
				Else
					nItensNeg ++
				EndIf
			EndIf
			If nPos2 > 0
				If  aColsITEn[nFor,nPos2] == "1"
					nAuditAut ++
				Else
					nAuditNeg ++
				EndIf
			EndIf
		EndIf
	Next
	
	// Consultando a guia principal caso seja um anexo que não tem procedimento (radioterapia)
	If !lTemProc
		cGuiRef := aDadCab[aScan(aDadCab, {|x| x[1] == "B4A_GUIREF"})][2] //Procurando a guia de referencia no array dados
		cMesRef := aDadCab[aScan(aDadCab, {|x| x[1] == "B4A_MESPAG"})][2]
		cAnoRef := aDadCab[aScan(aDadCab, {|x| x[1] == "B4A_ANOPAG"})][2]
		
		//se tiver registro na b4q significa que este anexo de radioterapia está sendo feito para a prorrogação de internação
		//pois só é possível inserir uma prorrogação de internação após a internação já ter sida aprovada em auditoria, neste caso, 
		//verifico o status da última prorrogação e repasso ela pro anexo para ser auditada também. 
		cQuery :=  " SELECT *"
		cQuery += " FROM " + RetSqlName("B4Q") + " B4Q "
		cQuery += " WHERE "
		cQuery += " B4Q_FILIAL = '"+xFilial("B4Q")+"' "
		cQuery += " AND B4Q_NUMAUT = (SELECT MAX(B4Q_NUMAUT) FROM " + RetSqlName("B4Q") + "WHERE B4Q_GUIREF = '"+cGuiRef+"')"   
		cQuery += " AND B4Q_MESAUT = '"+cMesRef+"' "
		cQuery += " AND B4Q_ANOAUT = '"+cAnoRef+"' "
		cQuery += " AND B4Q_CANCEL = '0' "
		cQuery += " AND B4Q.D_E_L_E_T_ = ' ' 
		cQuery += " ORDER BY B4Q.R_E_C_N_O_ DESC" 
			
		cQuery := ChangeQuery(cQuery)
			
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QRYB4Q",.F.,.T.)

		While !QRYB4Q->(Eof())
			cStGuiaPai := QRYB4Q->B4Q_STATUS
			QRYB4Q->(dbSkip())
		EndDo
		
		DBCloseArea()
				
		//se o status da guia pai estiver vazio, é pq não é guia de prorrogação, então busco a guia principal (internação ou SADT)
		IF (empty(cStGuiaPai))
			BEA->(DbSetorder(1))
			BEA->(dbSeek(xFilial("BEA")+ cGuiRef)) //Buscando a guia pai da guia de anexo para espelhar o status caso seja radioterapia.
			cStGuiaPai	:= BEA->BEA_STATUS	
		EndIf
	EndIF
	
	//Verificando se o anexo deve ir para auditoria	 
	If nOpc == K_Incluir  .or. nOpc == K_Copiar
		If (!lTemProc .And. cStGuiaPai == "6") //Se não tem procedimento (radioterapia) mas a guia principal está em auditoria, grava o anexo com status de auditoria mas não grava na tabela de auditoria (B53)  
			aadd(aDadCab,{cAliasCab+"_AUDITO","1"})
			lAuditoria := .F.
		ElseIf (nAuditAut > 0 .And.  &(cAliasCab+"->(FieldPos('"+cAliasCab+"_AUDITO"+"'))") > 0) 
			aadd(aDadCab,{cAliasCab+"_AUDITO","1"})
			lAuditoria := .T.
		Else
			aadd(aDadCab,{cAliasCab+"_AUDITO","0"})
			lAuditoria := .F.
		Endif
	Else
		lAuditoria := (&(cAliasCab+"->"+cAliasCab+"_AUDITO")=="1")
	Endif
		
	If nOpc == K_Incluir .And. lGerSenha   .or. 	nOpc == K_Copiar .and. lGerSenha
		If ExistBlock("PLS09AL1")
			cSenhaPLS := ExecBlock("PLS09AL1",.F.,.F.,{cTp,.F.,dData})
		Else
			cSenhaPLS := PLSSenAut(dData)
		Endif
		AaDd(aDadCab,{cAliasCab+"_SENHA",cSenhaPLS})
	Endif
	
	//Verificando o Status da guia
	If Empty(cStatus) .and. ! lAuditoria	
		If !lTemProc .and. lVisGui //se não tem procedimento é radioterapia, portanto grava mesmo status da guia principal
			      cStatus :=  cStGuiaPai
		ElseIf ( nItensNeg == 0 .and. nItensAut >= 1 ) .or. !lTemProc
			cStatus := "1" //Autorizada
		ElseIf ( nItensNeg > 0  .and. nItensAut >= 1 )
			cStatus := "2" //Autorizada parcialmente
		ElseIf ( nItensNeg > 0 .and. nItensAut == 0 )
			cStatus := "3" //nao autorizada
		Endif
	ElseIf lAuditoria
		cStatus := "6" //Em análise pela auditoria
	Endif 
Endif

If nOpc <> K_Visualizar
	
	If Empty(Eval(bOpeMov))
		bOpeMov := { || PLSINTPAD() }
	Endif
	
	If cStatus == "3"
		If (nPos := Ascan(aDadCab,{|x| x[1] == cAliasCab+"_SENHA"})) == 0
			AaDd(aDadCab,{cAliasCab+"_SENHA",""})
		Else
			aDadCab[nPos,2] := ""
		Endif
	EndIf
	
	
	If nOpc <> K_Copiar
		cOpeMov := &(cAliasCab+"->"+cAliasCab+"_OPEMOV")
		cAnoAut := &(cAliasCab+"->"+cAliasCab+"_ANOAUT")
		cMesAut := &(cAliasCab+"->"+cAliasCab+"_MESAUT")
		cNumAut := &(cAliasCab+"->"+cAliasCab+"_NUMAUT")
	Endif
	
	If nOpc <> K_Excluir
		cOpeMov := Eval(bOpeMov)
		cAnoAut := Eval(bAnoAut)
		cMesAut := Eval(bMesAut)
		If nOpc <> K_Copiar
			cNumAut := PlNewNAut(cAliasCab,cOpeMov,cAnoAut,cMesAut,nOpc)
		Endif
	EndIf
	
	If nOpc == K_Copiar
		cAnoAut := cAnoPag
		cMesAut := cMesPag
		cNumAut := PlNewNAut(cAliasCab,cOpeMov,cAnoAut,cMesAut,nOpc)
	Endif
	
	// O PlNewNAut deve estar fora do Begin Transaction para 
	// evitar que o sistema utilize a mesma numeracao para 
	// guias distintas
	Begin Transaction
	
		nPos   := PLRETPOS(cAliasIte+"_STATUS",aHeadIten,.F.)
		nPos2  := PLRETPOS(cAliasIte+"_AUDITO",aHeadIten,.F.)
		nPos02 := PLRETPOS(cAliasIte+"_QTDPRO",aHeadIten,.F.)
		nPos01 := PLRETPOS(cAliasIte+"_SEQUEN",aHeadIten,.F.)
		nPos03 := PLRETPOS(cAliasIte+"_CODPAD",aHeadIten,.F.)
		nPos04 := PLRETPOS(cAliasIte+"_CODPRO",aHeadIten,.F.)
		
		If nOpc == K_Incluir .or. 	nOpc == K_Copiar
			If (!lTemProc .And. cStGuiaPai == "6") //Se não tem procedimento (radioterapia) mas a guia principal está em auditoria, grava o anexo com status de auditoria mas não grava na tabela de auditoria (B53)
				aadd(aDadCab,{cAliasCab+"_AUDITO","1"})
				lAuditoria := .F.
			ElseIf (nAuditAut > 0 .And.  &(cAliasCab+"->(FieldPos('"+cAliasCab+"_AUDITO"+"'))") > 0)
				aadd(aDadCab,{cAliasCab+"_AUDITO","1"})
				lAuditoria := .T.
			Else
				aadd(aDadCab,{cAliasCab+"_AUDITO","0"})
				lAuditoria := .F.
			Endif
		Else
			lAuditoria := (&(cAliasCab+"->"+cAliasCab+"_AUDITO")=="1")
		Endif
		
		//===========================================================================
		//³ Exclusao																  ³
		//===========================================================================
		If nOpc == K_Excluir
			
			cChaveAut := &(cAliasCab+"->("+cAliasCab+"_OPEMOV+"+cAliasCab+"_ANOAUT+"+cAliasCab+"_MESAUT+"+cAliasCab+"_NUMAUT)")

			B43->(DbSetOrder(2))//B43_FILIAL + B43_OPEMOV + B43_ANOAUT + B43_MESAUT + B43_NUMAUT + B43_SEQUEN
			While B43->(MsSeek(xFilial("B43")+cChaveAut))
				B43->(RecLock("B43",.F.))
				B43->(DbDelete())
				B43->(MsUnLock())
			Enddo		
			
		Endif
		
		
		//gravacao do cabecalho
		B4A->( RecLock("B4A",(nOpc == K_Incluir) .or. nOpc == K_Copiar ) )
		If nOpc <> K_Excluir
			For nFor := 1 To Len(aDadCab)
				If AsCan(aCpoChv,{|x| x == aDadCab[nFor,1]}) == 0 .And. &( "B4A->( FieldPos('"+aDadCab[nFor,1]+"') )" ) > 0
					&("B4A->"+aDadCab[nFor,1]) := aDadCab[nFor,2]
				Endif
			Next
			If nOpc == K_Incluir .or.  nOpc == K_Copiar
				B4A->B4A_FILIAL := xFilial("B4A")
				B4A->B4A_OPEMOV := cOpeMov
				B4A->B4A_ANOAUT := cAnoAut
				B4A->B4A_MESAUT := cMesAut
				B4A->B4A_NUMAUT := cNumAut
				B4A->B4A_STATUS := cStatus				
				If Empty(B4A->B4A_TPGRV)
					B4A->B4A_TPGRV  := cTpGrv
				Endif
				SX3->(DbsetOrder(1))
				If SX3->( MsSeek('B4A') )
					SX3->( DbSkip() )
					While ! SX3->( Eof() ) .And. SX3->X3_ARQUIVO == 'B4A'
						cFldTrbB4A := SX3->X3_CAMPO
						If AsCan(aCpoChv  ,{|x| alltrim(x)		== alltrim(cFldTrbB4A)})	== 0 .And. ;
							AsCan(aDadCab  ,{|x| alltrim(x[1])	== alltrim(cFldTrbB4A)})	== 0 .And. ;
							AsCan(aStrucCab,{|x| alltrim(x[1])	== alltrim(cFldTrbB4A)})	 > 0 .And. ;
							ValType("M->"+AllTrim(SX3->X3_CAMPO)) <> "U" .And. ValType(cAliasCab+"->"+cFldTrbB4A) <> "U"
							
							&(cAliasCab+"->"+cFldTrbB4A) := &("M->"+AllTrim(SX3->X3_CAMPO))
							
						Endif
						SX3->(DbSkip())
					Enddo
				Endif
				B4A->B4A_STTISS  := PLSANLSTIG(cStatus)
				//gravacao da descricao Operador
				If(B4A->(FieldPos("B4A_DESOPE")))>0
				 	 if ((empty(PLRETOPE())) .And. (lPortal))
                         B4A->B4A_DESOPE := "ELETRONICA" 
                     else
                         B4A->B4A_DESOPE := cRetOpe
                     EndIf
		        EndIf
		
			Endif
		Else
			B4A->(DbDelete())
		Endif
		B4A->( MsUnLock() )
		

		
		//gravo itens
		for nFor := 1 to len(aStrucCab)
			
			cCpoAux := cAliasIte + "_" + subs(aStrucCab[nFor,1],5,10)
			
			if (nPos := aScan(aChaveGen,{|x| x[1] == cCpoAux})) == 0 .and. ValType(cAliasIte + "->" + cCpoAux) <> "U" .and. aStrucCab[nFor,2] <> 'N'
				aadd(aChaveGen,{cCpoAux,&(cAliasCab+"->"+cAliasCab+"_"+Subs(cCpoAux,5,10))})
			endIf
			
		next
		
		If (nPos := Ascan(aChaveGen,{|x| x[1] == cAliasIte+"_OPEMOV"})) == 0
			aadd(aChaveGen,{cAliasIte+"_OPEMOV", &(cAliasCab+"->"+cAliasCab+"_OPEMOV") })
		Else
			aChaveGen[nPos,2] := &(cAliasCab+"->"+cAliasCab+"_OPEMOV")
		EndIf
		
		If nOpc == K_Copiar
			
			If (nPos := Ascan(aChaveGen,{|x| x[1] == cAliasIte+"_ANOAUT"})) == 0
				aadd(aChaveGen,{cAliasIte+"_ANOAUT",cAnoAut})
			Else
				aChaveGen[nPos,2] := cAnoAut
			EndIf
			
			If (nPos := Ascan(aChaveGen,{|x| x[1] == cAliasIte+"_MESAUT"})) == 0
				aadd(aChaveGen,{cAliasIte+"_MESAUT",cMesAut})
			Else
				aChaveGen[nPos,2] := cMesAut
			EndIf
			
			If (nPos := Ascan(aChaveGen,{|x| x[1] == cAliasIte+"_NUMAUT"})) == 0
				aadd(aChaveGen,{cAliasIte+"_NUMAUT",cNumAut})
			else
				aChaveGen[nPos,2] := cNumAut
			EndIf
		Else
			If (nPos := Ascan(aChaveGen,{|x| x[1] == cAliasIte+"_ANOAUT"})) == 0
				aadd(aChaveGen,{cAliasIte+"_ANOAUT",&(cAliasCab+"->"+cAliasCab+"_ANOAUT")})
			Else
				aChaveGen[nPos,2] := &(cAliasCab+"->"+cAliasCab+"_ANOAUT")
			EndIf
			
			If (nPos := Ascan(aChaveGen,{|x| x[1] == cAliasIte+"_MESAUT"})) == 0
				aadd(aChaveGen,{cAliasIte+"_MESAUT",&(cAliasCab+"->"+cAliasCab+"_MESAUT")})
			Else
				aChaveGen[nPos,2] := &(cAliasCab+"->"+cAliasCab+"_MESAUT")
			EndIf
			
			If (nPos := Ascan(aChaveGen,{|x| x[1] == cAliasIte+"_NUMAUT"})) == 0
				aadd(aChaveGen,{cAliasIte+"_NUMAUT",&(cAliasCab+"->"+cAliasCab+"_NUMAUT")})
			else
				aChaveGen[nPos,2] := &(cAliasCab+"->"+cAliasCab+"_NUMAUT")
			EndIf
			
		Endif
				
		PLUPTCOLS(cAliasIte,aColsIten,aHeadIten,aVetTrIten,If(nOpc=K_Copiar,3,nOpc),aChaveGen)
		
		//gravo criticas
		If Len(aDadCri) > 0
			//tiro as criticas sem descricao
			PLSAJUMAT(aCabCri,aDadCri,cAliasCri+"_DESGLO")
			
			aChaveGen := {}
			aadd(aChaveGen,{cAliasCri+"_OPEMOV",&(cAliasCab+"->"+cAliasCab+"_OPEMOV")})
			aadd(aChaveGen,{cAliasCri+"_ANOAUT",&(cAliasCab+"->"+cAliasCab+"_ANOAUT")})
			aadd(aChaveGen,{cAliasCri+"_MESAUT",&(cAliasCab+"->"+cAliasCab+"_MESAUT")})
			aadd(aChaveGen,{cAliasCri+"_NUMAUT",&(cAliasCab+"->"+cAliasCab+"_NUMAUT")})
			
			BEG->(DbSetOrder(1))//BEG_FILIAL+BEG_OPEMOV+BEG_ANOAUT+BEG_MESAUT+BEG_NUMAUT+BEG_SEQUEN
			If BEG->(DbSeek(xFilial("BEG")+&(cAliasCab+"->"+cAliasCab+"_OPEMOV")+;
				&(cAliasCab+"->"+cAliasCab+"_ANOAUT")+;
				&(cAliasCab+"->"+cAliasCab+"_MESAUT")+;
				&(cAliasCab+"->"+cAliasCab+"_NUMAUT")))
				
				cKeyCri := BEG->(BEG_FILIAL+BEG_OPEMOV+BEG_ANOAUT+BEG_MESAUT+BEG_NUMAUT)
				While !BEG->(Eof()) .and. xFilial("BEG")+BEG->(BEG_OPEMOV+BEG_ANOAUT+BEG_MESAUT+BEG_NUMAUT) == cKeyCri
					
					BEG->(RecLock("BEG",.F.))
					BEG->(DbDelete())
					BEG->(MsUnLock())
					
					BEG->(DbSkip())
				EndDo
			Endif
			
			If Len(aDadCri)>0
				PLUPTCOLS(cAliasCri,aDadCri,aCabCri,aTrbCri,If(nOpc=K_Copiar,3,nOpc),aChaveGen,.T.)
			EndIf
		EndIf
		
		//Historico de autorizacao forcada
		If ValType(aAutForAnx) == "A" .And. Len(aAutForAnx) > 0
			PLSFORHIS(nOpc,SubStr(&(cAliasCab+"->"+cAliasCab+"_TIPGUI"),Len(&(cAliasCab+"->"+cAliasCab+"_TIPGUI"))),cAliasCab,aAutForAnx,aCodCriHis)
		EndIf
		
		If nOpc == K_Incluir  .or. nOpc == K_Copiar
			If lAuditoria
				
				//===========================================================================
				//³ manda para a auditoria                                                   ³
				//===========================================================================
				o790C := PLSA790C():New(.T.)
				o790C:SetAuditoria(lAuditoria,.F.,.F.,.F.,.F.,aDadCri,aCabCri,__aCdCri187[1],"0","BEG",aColsIten,aHeadIten,"B4C", .T.,,)
				o790C:Destroy()
			EndIf
		EndIf

	End Transaction
	
Endif
	
Return({lRet,&(cAliasCab+"->"+cAliasCab+"_OPEMOV"),&(cAliasCab+"->"+cAliasCab+"_ANOAUT"),&(cAliasCab+"->"+cAliasCab+"_MESAUT"),;
		&(cAliasCab+"->"+cAliasCab+"_NUMAUT"),NIL,NIL,NIL,lAuditoria,cStatus,NIL,&(cAliasCab+"->"+cAliasCab+"_SENHA")})
               
  /*/                                                                          
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ A090FinaA ³ Autor ³ Daher	            ³ Data ³ 13.02.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Exibir dados da autorizacao/liberacao efetuada             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
/*/
Static Function A090FinaA(cOpeMov,cAnoAut,cMesAut,cNumAut,cCodOpeG,;
							oBrwPro,lAuditoria,lTemProc)
LOCAL cNomUser
LOCAL cSIM
LOCAL cNAO
LOCAL cNomRDA
LOCAL oDlgFinal
LOCAL cDescSimb := GetNewPar("MV_SIMB1","R$")
LOCAL oFontNum
LOCAL oFontAutor                                    
LOCAL oFontTit
LOCAL oSay                   
LOCAL nItensSIM := 0
LOCAL nItensNAO := 0            
LOCAL nVlrPF
LOCAL nVlrBPF          
LOCAL nVlrTPF
LOCAL nVlrTAD
LOCAL nPercPF
LOCAL aVlrPF
LOCAL nColAut
LOCAL oBot01,oBot02,oBot03
LOCAL cMsgObs := ""
//===========================================================================
//³ Define fontes utilizadas somente nesta funcao...                         ³
//===========================================================================
DEFINE FONT oFontNum NAME "Arial" SIZE 000,-016 BOLD
DEFINE FONT oFontAutor NAME "Arial" SIZE 000,-019 BOLD
DEFINE FONT oFontTit NAME "Arial" SIZE 000,-011 BOLD

If lAuditoria
	Aviso( "Auditoria", ; //"Auditoria"
	"Esta guia foi gravada e esta sendo analisada pela auditoria.",; //"Esta guia foi gravada e esta sendo analisada pela auditoria."
	{ 'Ok' }, 2 )
	Return
Endif
//===========================================================================
//³ ponto de entrada Bops 126389 - Inserção de Msg de Observação             ³
//===========================================================================
If ExistBlock("PLS09AF2")
	cMsgObs := ExecBlock("PLS09AF2",.F.,.F.,{cOpeMov,cAnoAut,cMesAut,cNumAut,cCodOpeG,oBrwPro,lAuditoria})
Endif
//===========================================================================
//³ Mostra Resumo da Autorizacao...                                          ³
//===========================================================================
DEFINE MSDIALOG oDlgFinal TITLE "Dados do Anexo Clinico" FROM 009,000 TO 024,070 OF GetWndDefault() 
If lTemProc
	nColAut := PLRETPOS("B4C_IMGSTA",oBrwPro:aHeader)
	aEval(oBrwPro:aCols,{ |aVet|  IF(!aVet[Len(oBrwPro:aHeader)+1],If(AllTrim(aVet[nColAut])=="ENABLE",nItensSIM++,nItensNAO++),nil) })
EndIf

cNomUser := TransForm(M->B4A_USUARI,PesqPict("BE1","BE1_USUARI"))+" - "+M->B4A_NOMUSR
cNomRDA  := M->B4A_NOMSOL
cSIM     := StrZero(nItensSIM,2)
cNAO     := StrZero(nItensNAO,2)

oBot02 := SButton():New(097, 035, 6, {|| Pergunte("PLA090",.F.),lImpGuiDir:=(mv_par01==1),Eval(bImpGuia),If(lImpGuiDir,oDlgFinal:End(),nil) },,.T.)
oBot02:cToolTip := "Imprimir o Anexo Clinico"

oBot01 := SButton():New(097, 005, 1, {|| oDlgFinal:End() },,.T.)
oBot01:cToolTip := "Fechar Tela"

oBot03 := SButton():New(097, 065, 5, {|| Pergunte("PLA090",.T.),lImpGuiDir:=(mv_par01==1) },,.T.)
oBot03:cToolTip := "Parametros Impressao"

@ 007,005 SAY oSay PROMPT 'Anexo'+" "+" Número   "  SIZE 220,010 OF oDlgFinal PIXEL FONT oFontNum 
@ 006,095 SAY oSay PROMPT cOpeMov+"."+cAnoAut+"."+cMesAut+"."+cNumAut SIZE 220,010 OF oDlgFinal PIXEL FONT oFontAutor COLOR CLR_HRED

If nItensSIM > 0 .And. ! Empty(B4A->B4A_SENHA)
   @ 005,230 SAY oSay PROMPT "Senha"  SIZE 220,010 OF oDlgFinal PIXEL 
   @ 014,150 SAY oSay PROMPT "[ "+B4A->B4A_SENHA+" ]" SIZE 220,010 OF oDlgFinal PIXEL FONT oFontAutor COLOR CLR_HRED
Endif

@ 025,005 SAY oSay PROMPT "Usuario              "  SIZE 220,010 OF oDlgFinal PIXEL 
@ 025,065 MSGET cNomUser                           SIZE 205,010 OF oDlgFinal WHEN .F. PIXEL FONT oFontTit COLOR CLR_HBLUE

@ 043,005 SAY oSay PROMPT "Solicitante"  SIZE 220,010 OF oDlgFinal PIXEL 
@ 043,065 MSGET cNomRDA                           SIZE 205,010 OF oDlgFinal WHEN .F. PIXEL FONT oFontTit COLOR CLR_HBLUE

@ 061,005 SAY oSay PROMPT "Itens Autorizados"  SIZE 220,010 OF oDlgFinal PIXEL 
@ 061,065 MSGET cSIM                               SIZE 004,010 OF oDlgFinal WHEN .F. PIXEL FONT oFontTit COLOR CLR_HBLUE

@ 079,005 SAY oSay PROMPT "Itens NAO Autorizados"  SIZE 220,010 OF oDlgFinal PIXEL  
@ 079,065 MSGET cNAO                               SIZE 004,010 OF oDlgFinal WHEN .F. PIXEL FONT oFontTit COLOR CLR_HBLUE

If !Empty(cMsgObs)
	@ 079,082 SAY oSay PROMPT SubStr(cMsgObs,1,60) SIZE 220,010 OF oDlgFinal PIXEL COLOR CLR_HRED 
EndIf

ACTIVATE MSDIALOG oDlgFinal CENTERED on init if(Type('oBot02') == "O",oBot02:SetFocus(),Nil)

Return
                      
  /*/                                                                          
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLS090MAao ³ Autor ³ Daher	            ³ Data ³ 13.02.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Exibir dados da autorizacao/liberacao efetuada             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
/*/
Function PLS090MAao(cChave,cTipo,aCabProc,aTrbProc,aDadProc,cAlias)

LOCAL aAux := {}
LOCAL lRet := .T.

B4C->(DbSetOrder(1))
B4C->(MsSeek(xFilial("B4C")+cChave))
STORE COLS "B4C" TO aAux FROM aCabProc VETTRAB aTrbProc While xFilial("B4C")+cChave == B4C->(B4C_FILIAL+B4C_OPEMOV+B4C_ANOAUT+B4C_MESAUT+B4C_NUMAUT)

If Len(aAux) == 0 .and. cAlias == "B4C"
	Help("",1,"PLS090ITEN")
   Return
   lRet := .F.
Endif

aDadProc := aClone(aAux)

Return(lRet)                                           
  /*/                                                                          
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLS09AIm2 ³ Autor ³ Daher	            ³ Data ³ 13.02.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Exibir dados da autorizacao/liberacao efetuada             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
/*/                     
Function PLS09AIm2()
	PLS09AIma(.F.,'')
Return
  /*/                                                                          
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLS09AIma ³ Autor ³ Daher	            ³ Data ³ 13.02.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Exibir dados da autorizacao/liberacao efetuada             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
/*/
Function PLS09AIma(lWeb,cPath)
LOCAL aDados 		:= {}
LOCAL cTp    		:= B4A->B4A_TIPGUI         
LOCAL lImpNAut		:= IIf(GetNewPar("MV_PLNAUT",0) == 0, .F., .T.) // 0 = Nao imprime procedimento nao autorizado 1 = Sim imprime      
LOCAL aCpo13 		:= {}
LOCAL aCpo14 		:= {}
LOCAL aCpo15 		:= {}
LOCAL aCpo16 		:= {}
LOCAL aCpo17 		:= {}
LOCAL aCpo18 		:= {}
LOCAL aCpo19 		:= {}
LOCAL aCpo20 		:= {}
LOCAL aCpo21 		:= {}
LOCAL aCpo22 		:= {}
LOCAL aCpo23 		:= {}
LOCAL aCpo29 		:= {}
LOCAL aCpo30 		:= {}
LOCAL aCpo31 		:= {}
LOCAL aCpo32 		:= {}
LOCAL aCpo33 		:= {}
LOCAL aCpo34 		:= {}
LOCAL aCpo35 		:= {}
LOCAL aCpo36 		:= {}
LOCAL aCpo37 		:= {}
LOCAL aCpo38 		:= {}
LOCAL aCpo39 		:= {}
LOCAL cMsg 	 		:= ""
LOCAL cArqNa 		:= ""
LOCAL cVerTiss		:= ""
local lExsNomSoc	:= B4A->(FieldPos("B4A_NOMSOC")) > 0
DEFAULT lWeb 		:= .F.
DEFAULT cPath		:= ''

If B4A->B4A_STATUS == '6'
	cMsg := 'Guia em auditoria. Impressão não disponível.'
Endif

If B4A->B4A_CANCEL == '1'
	cMsg := 'Guia cancelada. Impressão não disponível.'
Endif

If B4A->B4A_STATUS == '0'
	cMsg := 'Guia não autorizada. Impressão não disponível.'
Endif

If !Empty(cMsg)
	If !lWeb
		MsgStop(cMsg)
		return {.F.,cMsg,cArqNa}
	Else
		return {.F.,cMsg,cArqNa}
	Endif
Endif

If cTp == '08'

	aDados  := { {Posicione("BA0",1,xFilial("B4A")+B4A->B4A_OPEMOV,"BA0_SUSEP"),; //1 - Registro ANS
	{If(B4A->(FieldPos("B4A_GUIPRE"))>0 .AND. !Empty(B4A->B4A_GUIPRE),B4A->B4A_GUIPRE,B4A->(B4A_OPEMOV + B4A_ANOAUT + B4A_MESAUT + B4A_NUMAUT))},; //2 - N Guia no Prestador
	{B4A->B4A_GUIREF},; //3 - Numero da Guia Referenciada
	{B4A->B4A_SENHA},; //4 - Senha
	{B4A->B4A_DATPRO},; //5 - Data da Autorizacao
	{IIf(!Empty(B4A->B4A_GUIOPE),B4A->B4A_GUIOPE,B4A->(B4A_OPEMOV + B4A_ANOAUT + B4A_MESAUT + B4A_NUMAUT))},; //6 - Numero da Guia Atribuido pela Operadora
	{B4A->(B4A_OPEUSR+B4A_CODEMP+B4A_MATRIC+B4A_TIPREG+B4A_DIGITO)},; //7 - Número da Carteira
	{B4A->B4A_NOMUSR},; //8 - Nome
	{B4A->B4A_IDADE},; //9 - Idade
	{iIF(Alltrim(B4A->B4A_SEXO)="2","3",B4A->B4A_SEXO)},; //10 - Sexo
	{B4A->B4A_NOMSOL},; //11 - Nome do Profissional Solicitante
	{B4A->B4A_TELSOL},; //12 - Telefone
	{B4A->B4A_EMASOL},; //13 - E-mail
	{B4A->B4A_DATDIA},; //14 - Data do diagnóstico
	{B4A->B4A_CIDPRI},; //15 - CID 10 Principal
	{B4A->B4A_CIDSEC},; //16 - CID 10 (2)
	{B4A->B4A_CIDTER},; //17 - CID 10 (3)
	{B4A->B4A_CIDQUA},; //18 - CID 10 (4)
	{B4A->B4A_DIAIMG},; //19 - Diagnosticpo por imagem
	{B4A->B4A_ESTADI},; //20 - Estadiamento
	{B4A->B4A_ECOG},; //21 - ECOG
	{B4A->B4A_FINALI},; //22 - Finalidade
	{B4A->B4A_DIAGCH},; //23 - Diagnóstico Cito/Histopatológico
	{B4A->B4A_INFREL},; //24 - Informações relevantes
	{B4A->B4A_CIRURG},; //25- Cirurgia
	{B4A->B4A_DATCIR},; //26 - Data da Realização
	{B4A->B4A_QUIMIO},; //27 - Quimioterapia
	{B4A->B4A_DATQUI}}} //28 - Data da Aplicação},; //28 - Data da Aplicação
	
	cVerTiss := PLSTISSVER()
	IF (cVerTiss > "3.02") //TISS 3.03.01
				
		aadd(aDados[1],{B4A->B4A_NROCAM}) //29 - Número de Campos
		aadd(aDados[1],{B4A->B4A_DOSDIA}) //30 - Dose por dia (em Gy)
		aadd(aDados[1],{B4A->B4A_DOSTOT}) //31 - Dose Total ( em Gy)
		aadd(aDados[1],{B4A->B4A_NRODIA}) //32 - Número de Dias
		aadd(aDados[1],{B4A->B4A_DATPRE}) //33 - Data Prevista para Início da Administração
		aadd(aDados[1],{B4A->B4A_OBSERV}) //34-Observação/Justificativa
		aadd(aDados[1],{B4A->B4A_DATSOL}) //35 - Data da Solicitação
		aadd(aDados[1],{''}) //36-Assinatura do Profissional Solicitante
		aadd(aDados[1],{''}) //37-Assinatura do Autorizador da Operadora
		aadd(aDados[1],{Iif(lExsNomSoc, B4A->B4A_NOMSOC, "" )}  ) //38-Nome Social

	cArqNa := PLTISARADI(aDados, nil, nil,lWeb, cPath)
	Else // TISS 3.02.01
		B4C->(DbSetOrder(1))
		If B4C->(MsSeek(xFilial('B4C')+B4A->(B4A_OPEMOV + B4A_ANOAUT + B4A_MESAUT + B4A_NUMAUT)))
			While !B4C->(Eof()) .and. B4A->(B4A_OPEMOV + B4A_ANOAUT + B4A_MESAUT + B4A_NUMAUT) == B4C->(B4C_OPEMOV + B4C_ANOAUT + B4C_MESAUT + B4C_NUMAUT)
		        
				If (B4C->B4C_STATUS == '0' .And. lImpNAut) .Or. B4C->B4C_STATUS == '1'				
					aadd(aCpo29,B4C->B4C_DATPRO)
					aadd(aCpo30,PLSGETVINC('BTU_CDTERM', 'BR4', .F., '87', ALLTRIM(B4C->B4C_CODPAD)))
					aadd(aCpo31,B4C->B4C_CODPRO)
					aadd(aCpo32,B4C->B4C_DESPRO)
					aadd(aCpo33,Iif(B4C->B4C_STATUS == '0',0,B4C->B4C_QTDPRO))
				Endif
				B4C->(DbSkip())
			Enddo
		Endif
		
		aadd(aDados[1],{aCpo29}) //29-Data Prevista para Administração
		aadd(aDados[1],{aCpo30}) //30-Tabela
		aadd(aDados[1],{aCpo31}) //31-Código do Procedimento
		aadd(aDados[1],{aCpo32}) //32-Descrição
		aadd(aDados[1],{aCpo33}) //33-Qtd
		aadd(aDados[1],{B4A->B4A_NROCAM}) //34 - Número de Campos
		aadd(aDados[1],{B4A->B4A_DOSDIA}) //35 - Dose por dia (em Gy)
		aadd(aDados[1],{B4A->B4A_DOSTOT}) //36 - Dose Total ( em Gy)
		aadd(aDados[1],{B4A->B4A_NRODIA}) //37 - Número de Dias
		aadd(aDados[1],{B4A->B4A_DATPRE}) //38 - Data Prevista para Início da Administração
		aadd(aDados[1],{B4A->B4A_OBSERV}) //39-Observação/Justificativa
		aadd(aDados[1],{B4A->B4A_DATSOL}) //40 - Data da Solicitação
		aadd(aDados[1],{''} )//41-Assinatura do Profissional Solicitante
		aadd(aDados[1],{''} ) //42-Assinatura do Autorizador da Operadora
	
		cArqNa := PLTISARAD2(aDados, nil, nil,lWeb, cPath)
	EndIf


ElseIf cTp == '07'
	
	B4C->(DbSetOrder(1))
	Posicione("BA0",1,xFilial("B4A")+B4A->B4A_OPEMOV,"BA0_SUSEP")
//	aDados  := { {Posicione("BA0",1,xFilial("B4A")+B4A->B4A_OPEMOV,"BA0_SUSEP"),; //1 - Registro ANS
	If B4C->(MsSeek(xFilial('B4C')+B4A->(B4A_OPEMOV + B4A_ANOAUT + B4A_MESAUT + B4A_NUMAUT)))
		While !B4C->(Eof()) .and. B4A->(B4A_OPEMOV + B4A_ANOAUT + B4A_MESAUT + B4A_NUMAUT) == B4C->(B4C_OPEMOV + B4C_ANOAUT + B4C_MESAUT + B4C_NUMAUT)
	        
			If (B4C->B4C_STATUS == '0' .And. lImpNAut) .Or. B4C->B4C_STATUS == '1'
		        aadd(aCpo32,B4C->B4C_DATPRO)          
		        aadd(aCpo33,PLSGETVINC('BTU_CDTERM', 'BR4', .F., '87', ALLTRIM(B4C->B4C_CODPAD)))
		        aadd(aCpo34,B4C->B4C_CODPRO)
		        aadd(aCpo35,B4C->B4C_DESPRO)
		        aadd(aCpo36,Iif(B4C->B4C_STATUS == '0',0,B4C->B4C_QTDPRO))
		        If B4C->(FieldPos("B4C_UNMED"))>0
		        	aadd(aCpo37,B4C->B4C_UNMED)
		        Elseif BA0->BA0_TISVER < "3.03.00"
		        	aadd(aCpo37,"")
		        	//Não faz nada, só funciona
		        else
		        	MsgInfo("Para o funcionamento correto da rotina execute o compatibilizador do chamado TVILYR, que contempla as alterações da TISS 3.03.00")
		        	Return ()
		        EndIf
		        aadd(aCpo38,B4C->B4C_VIAADM)
		        aadd(aCpo39,B4C->B4C_FREQUE)
			Endif
			B4C->(DbSkip())
		Enddo
	Endif
	aDados  := { {Posicione("BA0",1,xFilial("B4A")+B4A->B4A_OPEMOV,"BA0_SUSEP"),; //1 - Registro ANS
	{If(B4A->(FieldPos("B4A_GUIPRE"))>0 .AND. !Empty(B4A->B4A_GUIPRE),B4A->B4A_GUIPRE,B4A->(B4A_OPEMOV + B4A_ANOAUT + B4A_MESAUT + B4A_NUMAUT))},; //2 - N Guia no Prestador
	{B4A->B4A_GUIREF},; //3 - Numero da Guia Referenciada
	{B4A->B4A_SENHA},; //4 - Senha
	{B4A->B4A_DATPRO},; //5 - Data da Autorizacao
	{IIf(!Empty(B4A->B4A_GUIOPE),B4A->B4A_GUIOPE,B4A->(B4A_OPEMOV + B4A_ANOAUT + B4A_MESAUT + B4A_NUMAUT))},; //6 - Numero da Guia Atribuido pela Operadora
	{B4A->(B4A_OPEUSR+B4A_CODEMP+B4A_MATRIC+B4A_TIPREG+B4A_DIGITO)},; //7 - Número da Carteira
	{B4A->B4A_NOMUSR},; //8 - Nome
	{B4A->B4A_PESO},; //9 - Peso (Kg)
	{B4A->B4A_ALTURA},; //10 - Altura (Cm)
	{B4A->B4A_SUPCOR},; //11 - Superfície Corporal (m²)
	{B4A->B4A_IDADE},; //12 - Idade
	{iIF(Alltrim(B4A->B4A_SEXO)="2","3",B4A->B4A_SEXO)},; //13 - Sexo
	{B4A->B4A_NOMSOL},; //14 - Nome do Profissional Solicitante
	{B4A->B4A_TELSOL},; //15 - Telefone
	{B4A->B4A_EMASOL},; //16 - E-mail
	{B4A->B4A_DATDIA},; //17 - Data do diagnóstico
	{B4A->B4A_CIDPRI},; //18 - CID 10 Principal
	{B4A->B4A_CIDSEC},; //19 - CID 10 (2)
	{B4A->B4A_CIDTER},; //20 - CID 10 (3)
	{B4A->B4A_CIDQUA},; //21 - CID 10 (4)
	{B4A->B4A_ESTADI},; //22 - Estadiamento
	{B4A->B4A_TIPQUI},; //23 - Tipo de Quimioterapia
	{B4A->B4A_FINALI},; //24 - Finalidade
	{B4A->B4A_ECOG}	,; //25 - ECOG
	{IIF( B4A->(FieldPos("B4A_TUMOR")) <= 0 , "", B4A->B4A_TUMOR)}	,; //26 - Tumor
	{IIF( B4A->(FieldPos("B4A_NODULO")) <= 0 , "", B4A->B4A_NODULO)}	,; //27 - Nódulo
	{IIF( B4A->(FieldPos("B4A_METAST")) <= 0, "", B4A->B4A_METAST)} ,; //28 - Metastase 
	{B4A->B4A_PLATER},; //29 - PlanoTerapêutico
	{B4A->B4A_DIAGCH},; //30 - Diagnóstico Cito/Histopatológico
	{B4A->B4A_INFREL},; //31 - Informações relevantes
	{aCpo32},; //32-Data Prevista para Administração
	{aCpo33},; //33-Tabela
	{aCpo34},; //34-Código do Medicamento
	{aCpo35},; //35-Descrição
	{aCpo36},; //36-Doses
	{aCpo37},;	//37-Unidade de Medida
	{aCpo38},; //38-Via Adm
	{aCpo39},; //39-Frequência
	{B4A->B4A_CIRURG},; //40- Cirurgia
	{B4A->B4A_DATCIR},; //41 - Data da Realização
	{B4A->B4A_AREA},;   //42 - Área Irradiada
	{B4A->B4A_DATIRR},; //43 - Data da Aplicação
	{B4A->B4A_OBSERV},; //44 - Observação
	{B4A->B4A_NROCIC},; //45 - Número de Ciclos Previstos
	{B4A->B4A_CICATU},; //46 - Ciclo Atual
	{IIF( B4A->(FieldPos("B4A_DCICAT")) <= 0 , 0, B4A->B4A_DCICAT)},; //47 - Número de dias do ciclo atual
	{B4A->B4A_INTCIC},; //48-Intervalo entre Ciclos ( em dias)
	{B4A->B4A_DATSOL},; //49 - Data da Solicitação
	{""},; //50-Assinatura do Profissional Solicitante
	{""},; //51-Assinatura do Responsável pela Autorização
	{Iif(lExsNomSoc, B4A->B4A_NOMSOC, "" )} } }//52-Nome social
	cArqNa := PLTISAQUIM(aDados, nil, nil,lWeb, cPath)

ElseIf cTp == '09'

	cVerTiss := PLSTISSVER()
	B4C->(DbSetOrder(1))
	If B4C->(MsSeek(xFilial('B4C')+B4A->(B4A_OPEMOV + B4A_ANOAUT + B4A_MESAUT + B4A_NUMAUT)))
		While !B4C->(Eof()) .and. B4A->(B4A_OPEMOV + B4A_ANOAUT + B4A_MESAUT + B4A_NUMAUT) == B4C->(B4C_OPEMOV + B4C_ANOAUT + B4C_MESAUT + B4C_NUMAUT)
	    	If (B4C->B4C_STATUS == '0' .And. lImpNAut) .Or. B4C->B4C_STATUS == '1'
			
				aadd(aCpo13,Iif(PLSIMPRIM(cTp,cVerTiss,"B4C_CODPAD"),PLSGETVINC('BTU_CDTERM', 'BR4', .F., '87', ALLTRIM(B4C->B4C_CODPAD)),""))
				aadd(aCpo14,Iif(PLSIMPRIM(cTp,cVerTiss,"B4C_CODPRO"),B4C->B4C_CODPRO,""))
				aadd(aCpo15,Iif(PLSIMPRIM(cTp,cVerTiss,"B4C_DESPRO"),B4C->B4C_DESPRO,""))
				aadd(aCpo16,Iif(PLSIMPRIM(cTp,cVerTiss,"B4C_OPCAO"),B4C->B4C_OPCAO,""))
				aadd(aCpo17,Iif(PLSIMPRIM(cTp,cVerTiss,"B4C_QTDSOL"),B4C->B4C_QTDSOL,))
				aadd(aCpo18,Iif(PLSIMPRIM(cTp,cVerTiss,"B4C_VLRUNT"),B4C->B4C_VLRUNT,))
				aadd(aCpo19,Iif(PLSIMPRIM(cTp,cVerTiss,"B4C_QTDPRO"),Iif(B4C->B4C_STATUS == '0',0,B4C->B4C_QTDPRO),))
				aadd(aCpo20,Iif(PLSIMPRIM(cTp,cVerTiss,"B4C_VLRUNA"),Iif(B4C->B4C_STATUS == '0',0,B4C->B4C_VLRUNA),))
				aadd(aCpo21,Iif(PLSIMPRIM(cTp,cVerTiss,"B4C_REGANV"),B4C->B4C_REGANV,""))
				aadd(aCpo22,Iif(PLSIMPRIM(cTp,cVerTiss,"B4C_REFMAF"),B4C->B4C_REFMAF,""))
				aadd(aCpo23,Iif(PLSIMPRIM(cTp,cVerTiss,"B4C_AUTFUN"),B4C->B4C_AUTFUN,""))
			Endif
			B4C->(DbSkip())	
		Enddo
	Endif
	aDados := { {Iif(PLSIMPRIM(cTp,cVerTiss,"B4A_REGANS"),Posicione("BA0",1,xFilial("B4A")+B4A->B4A_OPEMOV,"BA0_SUSEP"),""),; //1 - Registro ANS
	{Iif(PLSIMPRIM(cTp,cVerTiss,"B4A_GUIPRE"),Iif(B4A->(FieldPos("B4A_GUIPRE")) > 0 .AND. !Empty(B4A->B4A_GUIPRE),B4A->B4A_GUIPRE,B4A->(B4A_OPEMOV + B4A_ANOAUT + B4A_MESAUT + B4A_NUMAUT)), "")},; //2 - N Guia no Prestador
	{Iif(PLSIMPRIM(cTp,cVerTiss,"B4A_GUIREF"),B4A->B4A_GUIREF,"")},; //3 - Numero da Guia Referenciada
	{Iif(PLSIMPRIM(cTp,cVerTiss,"B4A_SENHA"),B4A->B4A_SENHA,"")},; //4 - Senha
	{Iif(PLSIMPRIM(cTp,cVerTiss,"B4A_DATPRO"),B4A->B4A_DATPRO, cTod(" / / "))},; //5 - Data da Autorizacao
	{Iif(PLSIMPRIM(cTp,cVerTiss,"B4A_GUIOPE"),IIf(!Empty(B4A->B4A_GUIOPE),B4A->B4A_GUIOPE,B4A->(B4A_OPEMOV + B4A_ANOAUT + B4A_MESAUT + B4A_NUMAUT)),"")},; //6 - Numero da Guia Atribuido pela Operadora
	{Iif(PLSIMPRIM(cTp,cVerTiss,"B4A_USUARI"),B4A->(B4A_OPEUSR+B4A_CODEMP+B4A_MATRIC+B4A_TIPREG+B4A_DIGITO),"")},; //7 - Número da Carteira
	{Iif(PLSIMPRIM(cTp,cVerTiss,"B4A_NOMUSR"),B4A->B4A_NOMUSR,"")},; //8 - Nome
	{Iif(PLSIMPRIM(cTp,cVerTiss,"B4A_NOMSOL"),B4A->B4A_NOMSOL,"")},; //9 - Nome do Profissional Solicitante
	{Iif(PLSIMPRIM(cTp,cVerTiss,"B4A_TELSOL"),B4A->B4A_TELSOL,"")},; //10 - Telefone
	{Iif(PLSIMPRIM(cTp,cVerTiss,"B4A_EMASOL"),B4A->B4A_EMASOL,"")},; //11 - E-mail
	{Iif(PLSIMPRIM(cTp,cVerTiss,"B4A_JUSTTE"),B4A->B4A_JUSTTE,"")},; //12 - Justificativs
	{aCpo13},; //13
	{aCpo14},; //14
	{aCpo15},; //15
	{aCpo16},; //16
	{aCpo17},; //17
	{aCpo18},; //18
	{aCpo19},; //19
	{aCpo20},; //20
	{aCpo21},; //21
	{aCpo22},; //22
	{aCpo23},; //23
	{Iif(PLSIMPRIM(cTp,cVerTiss,"B4A_ESPMAT"),B4A->B4A_ESPMAT, "")},; //24 - Data da Aplicação
	{Iif(PLSIMPRIM(cTp,cVerTiss,"B4A_OBSERV"),B4A->B4A_OBSERV,"")},; //25 - Observação
	{Iif(PLSIMPRIM(cTp,cVerTiss,"B4A_DATSOL"),B4A->B4A_DATSOL, cTod(" / / "))},; //44 - Data da Solicitação
	{""},; //45-Assinatura do Profissional Solicitante
	{""},; //46-Assinatura do Responsável pela Autorização
	{Iif(PLSIMPRIM(cTp,cVerTiss,"B4A_NOMSOC"),B4A->B4A_NOMSOC,"")}}}  //47-Nome social

	cArqNa := PLTISAOPME(aDados, nil, nil,lWeb, cPath)

Endif

Return {.T.,cMsg,cArqNa}

  /*/                                                                          
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSA09Aprt ³ Autor ³ Daher	            ³ Data ³ 17.02.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Exibir dados da autorizacao/liberacao efetuada             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
/*/

Function PLSA09Aprt(lValid)
LOCAL cRet    := "@#.T."
LOCAL cTabela := '' 
LOCAL lRet    := .F.
DEFAULT lValid  := .F.

If alltrim(Readvar()) $ 'M->B4A_SEXO/B4A->B4A_SEXO'   
	cTabela := "43"
ElseIf alltrim(Readvar()) $ 'M->B4A_ESTADI/B4A->B4A_ESTADI'
	cTabela := "31"
ElseIf alltrim(Readvar()) $ 'M->B4A_DIAIMG/B4A->B4A_DIAIMG'
	cTabela := "29"	
ElseIf alltrim(Readvar()) $ 'M->B4A_FINALI/B4A->B4A_FINALI'
	cTabela := "33"
ElseIf alltrim(Readvar()) $ 'M->B4A_GRAUPA/B4A->B4A_GRAUPA'
	cTabela := "35"
ElseIf alltrim(Readvar()) $ 'M->B4A_TIPQUI/B4A->B4A_TIPQUI'
	cTabela := "58"
ElseIf alltrim(Readvar()) $ 'M->B4A_ECOG/B4A->B4A_ECOG'
	cTabela := "30"                      
ElseIf alltrim(Readvar()) $ 'M->B4C_VIAADM/B4C->B4C_VIAADM'
	cTabela := "62"                      
ElseIf alltrim(Readvar()) $ 'M->B4A_TUMOR'  
	cTabela := "67" 
ElseIf alltrim(Readvar()) $ 'M->B4A_NODULO' 
	cTabela := "66" 
ElseIf alltrim(Readvar()) $ 'M->B4A_METAST' 
	cTabela := "65"        
ElseIf alltrim(Readvar()) $ 'M->B4C_UNMED' 
	cTabela := "60" 	
ElseIf (alltrim(Readvar()) $ 'M->BE1_AUSVLD/BEA->BEA_AUSVLD') .Or. (alltrim(Readvar()) $ 'M->BE4_AUSVLD/BE4->BE4_AUSVLD')
	cTabela := "74"
Endif
              
If !lValid    
	cRet := "@#BTQ_FILIAL == '"+xFilial("BTQ")+"' .AND. "
	cRet += "  BTQ_CODTAB == '"+cTabela+"' .AND. "
	cRet += "  (dtos(BTQ_VIGDE) <= '"+DTOS(dDataBase)+"' .OR. Empty(BTQ_VIGATE) ) .AND. "
	cRet += "  (dtos(BTQ_VIGATE) >= '"+DTOS(dDataBase)+"' .OR. Empty(BTQ_VIGATE)) "
	cRet += " @#" 
Else
	cRet := " SELECT BTQ_CDTERM A FROM "+RetSqlName('BTQ') 
	cRet += "  WHERE BTQ_FILIAL = '"+xFilial("BTQ")+"' AND "
	cRet += "  BTQ_CODTAB = '"+cTabela+"' AND "
	cRet += "  BTQ_CDTERM = '"+&(ReadVar())+"' AND "
	cRet += "  (BTQ_VIGDE <= '"+DTOS(dDataBase)+"' OR BTQ_VIGATE = ' ' ) AND "
	cRet += "  (BTQ_VIGATE >= '"+DTOS(dDataBase)+"' OR BTQ_VIGATE = ' ') AND "	
	cRet += "  D_E_L_E_T_ = ' ' "         
	PlsQuery(cRet,'TrbBTQ')
	If (!BTQ->(Eof()) .and. !Empty(TrbBTQ->A)) .or. Empty(&(ReadVar()))
		lRet := .T.
	Else
		Help("",1,"REGNOIS") 
		lRet := .F.
	Endif
	TrbBTQ->(DbCloseArea())
Endif
return {cRet,lRet}     
                                                    
/*/                                                                          
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSA0A2CAN ³ Autor ³ Daher	            ³ Data ³ 18.02.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Exibir dados da autorizacao/liberacao efetuada             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
/*/
         
Function PLSA0A2CAN(lAut,lAlert, aMotCanc)
LOCAL cMask		:= ""
LOCAL cFile		:= ""
LOCAL cLog			:= ""
LOCAL nI			:= ""
LOCAL oMemo
LOCAL oDlgLog
LOCAL __cFileLog	:= ""
LOCAL aMsg			:= {}
LOCAL aRecCan		:= {}
LOCAL lRet			:= .T.
DEFAULT lAut		:= .F.
DEFAULT lAlert		:= .T.
DEFAULT aMotCanc := {}

If !lAut // Quando chamA através de um cancelamento de anexo avulso pelo menu dos anexos clínicos
	
	aMotCanc := P090MTVCAN()

	if empty(aMotCanc[1]) .and. empty(aMotCanc[2])
		msgInfo("Informe um motivo válido!") //"Informe um motivo válido!"
		Return //Verificar essa validação
	EndIf
	
	PLSA09ACAN(.F., , , , , aMotCanc)
Else
	// Quando chama através do cancelamento de autorização sadt ou de cancelamento de internação
	While !B4A->(Eof()) .and. xFilial("B4A")+BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT) == xFilial("B4A")+B4A->B4A_GUIREF
		PLSA09ACAN(.F.,.T.,aMsg,aRecCan, ,aMotCanc)
		B4A->(DbSkip())
	EndDo
	
	If Len(aMsg) > 0
		lRet := .F.
		//Exibe o Log
		cLog := STR0044 + CRLF //"Detalhes do processamento"
		cLog += Replicate("-",25) + CRLF
		cLog += STR0045 + CRLF //"Esta autorização possui um ou mais Anexos Clinicos vinculados, com pendências no setor de auditoria. A guia não poderá ser cancelada."
		cLog += STR0046 + CRLF + CRLF //"Para dar continuidade, analise as pendências abaixo."
		cLog += STR0047 + CRLF //"GUIA / STATUS"
		cLog += Replicate("-",25) + CRLF
		
		For nI := 1 to Len(aMsg)
			cLog += aMsg[1] + CRLF
		Next
		
		__cFileLog := MemoWrite(Criatrab(,.f.) + ".LOG", cLog)
	
		DEFINE MSDIALOG oDlgLog TITLE STR0048 From 3,0 to 340,417 PIXEL //"Cancelamento de Anexos Clínicos"
		
		@ 5,5 GET oMemo  VAR cLog MEMO SIZE 200,145 OF oDlgLog PIXEL
		  oMemo:bRClicked := {||AllwaysTrue() } 
		
		DEFINE SBUTTON  FROM 153,175 TYPE 1 ACTION oDlgLog:End() ENABLE OF oDlgLog PIXEL //Apaga
		DEFINE SBUTTON  FROM 153,145 TYPE 13 ACTION (cFile:=cGetFile(cMask,""),If(cFile="",.t.,MemoWrite(cFile,cLog))) ENABLE OF oDlgLog PIXEL
		
		ACTIVATE MSDIALOG oDlgLog CENTER
		
		Return {lRet,.T.}
		
	Else
		If lAlert
			If !MsgYesNo(STR0049) //"Confirma o CANCELAMENTO da GUIA?"
				Return {.F.,.T.}
			EndIf
		EndIf
	
		For nI := 1 to Len(aRecCan)

			If aRecCan[nI][1] == "B4A"
				B4A->(DbGoTo(aRecCan[nI][2]))
				
				B4A->( RecLock("B4A", .F.) )
					B4A->B4A_STATUS := '3'
					B4A->B4A_CANCEL := '1'
					B4A->B4A_STTISS := '6'  //Cancelada
					
					if Len(aMotCanc) > 0
						B4A->B4A_CANTIS := aMotCanc[1] //Motivo TISS
						B4A->B4A_CANEDI := aMotCanc[2] //Texto motivo
					EndIf
					
				B4A->( MsUnLock() )
				
			EndIf

			If aRecCan[nI][1] == "B4C"
				B4C->(DbGoTo(aRecCan[nI][2]))
				
				B4C->( RecLock("B4C", .F.) )
					B4C->B4C_AUDITO := '0'
					B4C->B4C_STATUS := '0'
				B4C->( MsUnLock() )
				
			EndIf

			If aRecCan[nI][1] == "B53"
				B53->(DbGoTo(aRecCan[nI][2]))
				
				B53->(Reclock("B53",.F.))
					B53->B53_STATUS := '6'
				B53->(MsUnlock())
				
			EndIf
			
		Next
		
		Return {lRet,.T.,aRecCan}
	EndIf
EndIf

Return lRet

/*/{Protheus.doc} PLSA09ACAN
Cancelamento de Anexos Clinicos

@type function
@author Daher
@since 18/02/2014
@version 1.0
@param lWeb, lógico, identifica se a função esta sendo acionada via portal. Caso verdadeiro, o retorno da funcao sempre sera a mensagem a ser exibida no portal do prestador 
@param lAut, lógico, identifica se a função esta sendo acionada pelas rotinas de atendimento (SADT/Odonto/Internação). Caso verdadeiro, o sistema localiza todas os anexos vinculados a guia origem e somente cancela a guia caso todos os anexos possam ser cancelados. 
@param lAudito, Identifica se está cancelando a guia através da auditoria.
@param aMotCanc, Motivo TISS do cancelamento deste procedimento

@todo Validar se os procedimentos da guia já foram PAGOS/COBRADOS em alguma guia de SADT/INTERNACAO. Caso SIM, nao deixa cancelar

@return cMsg, Mensagem a ser exibida na tela (somente se chamada via portal)
/*/                                                                          

Function PLSA09ACAN(lWeb,lAut,aMsg,aRecCan,lAudito,aMotCanc,lRPC, nStatusTiss) 
LOCAL cFaseGuia := ""
LOCAL cSeqPF    := ""
LOCAL cMsg		:= ""
LOCAL cGuiRef	:= B4A->B4A_GUIREF
LOCAL lCanTis	:= B4A->( FieldPos("B4A_CANTIS") ) > 0
LOCAL lOk			:= .T.
Local lApagaGuia := GetNewPar("MV_PLAUDAN",.F.) // Determina que mesmo se a guia estiver na auditoria analise de auditoria podera ser excluida
DEFAULT aMsg		:= {}
DEFAULT aRecCan	:= {}
DEFAULT lWeb	:= .F.
DEFAULT lAut		:= .F.
DEFAULT lAudito := .F. 
DEFAULT aMotCanc := {}
DEFAULT lRPC := .F.
DEFAULT nStatusTiss	:= 0

//Guia cancelada
If B4A->B4A_CANCEL == '1'
	lOk := .F.
	cMsg := STR0050 //'O anexo já encontra-se CANCELADO!'

	//Vamos informar que a guia já foi cancelada guando vier de uma requisição da TISS online
	nStatusTiss := 1 //Guia cancelada com sucesso
	
	If !lWeb .And. !lAut .And. !lRPC
		Aviso( STR0031, ; //"Cancelar Anexo"
			   cMsg,; 
			   {"Ok"}, 2 )
	ElseIf lWeb
		Return cMsg
	ElseIf lAut
		Return  
	EndIf
	
EndIf      

If !lAudito 

	//Existem procedimentos em analise pela auditoria
	B53->(dbSetOrder(1))//B53_FILIAL + B53_NUMGUI + B53_ORIMOV
	If B53->(dbSeek(B4A->(B4A_FILIAL+B4A_OPEMOV+B4A_ANOAUT+B4A_MESAUT+B4A_NUMAUT)))
		If B53->B53_SITUAC $ '23'
			If !lApagaGuia
				lOk := .F.  
				cStatus := Iif(B53->B53_SITUAC == '2',"Em Analise","Em Espera")
				cMsg	:= STR0051 + cStatus //"Não será possivel cancelar o Anexo Clínico informado. Status da Guia:"
				
				If !lWeb .And. !lAut .And. !lRPC
					Alert(cMsg)
				ElseIf lWeb
					Return cMsg		
				ElseIf lAut
					aAdd(aMsg,TransForm(B4A->(B4A_OPEMOV+B4A_ANOAUT+B4A_MESAUT+B4A_NUMAUT),PesqPict("B4A","B4A_NUMLIB"))+ " / " + cStatus + CRLF) 
				EndIf
			Endif	
		EndIf
	EndIf
EndIf 

////Ponto de entrada apos validacao padrao
If ExistBlock("PL09ACKCAN")
	If !Execblock("PL09ACKCAN",.F.,.F.,{cGuiRef})
		Return
	EndIf
EndIf



If lOk
	
	If !lWeb .And. !lAut .And. !lAudito .And. !lRPC .And. !MsgYesNo(STR0052) //"Confirma o CANCELAMENTO do ANEXO?"
		Return 
	EndIf

//Atualiza o cabecalho
	
	If !lAut
		B4A->( RecLock("B4A", .F.) )
		B4A->B4A_STATUS := '3'
		B4A->B4A_CANCEL := '1'
		B4A->B4A_STTISS := '6'
		
		if Len(aMotCanc) > 0
			if !lWeb
				B4A->B4A_CANTIS := aMotCanc[1] //Motivo TISS
				B4A->B4A_CANEDI := aMotCanc[2] //Texto motivo
			else
				B4A->B4A_CANEDI := aMotCanc[1] //Texto motivo
			endif
		EndIf
		 
		B4A->( MsUnLock() )

		//Vamos informar que a guia foi cancelada guando vier de uma requisição da TISS online
		nStatusTiss := 1 //Guia cancelada com sucesso
	Else
		aAdd(aRecCan,{"B4A",B4A->(Recno())})	
	EndIf

	//Atualiza os itens
	B4C->( DbSetOrder(1) ) //B4C_FILIAL + B4C_OPEMOV + B4C_ANOAUT + B4C_MESAUT + B4C_NUMAUT + B4C_SEQUEN
	B4C->( MsSeek( xFilial("B4C")+B4A->(B4A_OPEMOV+B4A_ANOAUT+B4A_MESAUT+B4A_NUMAUT) ) )
	While !B4C->(Eof()) .And. B4A->(B4A_FILIAL+B4A_OPEMOV+B4A_ANOAUT+B4A_MESAUT+B4A_NUMAUT) == B4C->(B4C_FILIAL+B4C_OPEMOV+B4C_ANOAUT+B4C_MESAUT+B4C_NUMAUT)
		If !lAut
			B4C->( RecLock("B4C", .F.) )
			B4C->B4C_AUDITO := '0'
			B4C->B4C_STATUS := '0'
			B4C->( MsUnLock() )
		Else
			aAdd(aRecCan,{"B4C",B4C->(Recno())})				
		EndIf
		B4C->( DbSkip() )
	EndDo

	//Atualiza a auditoria
	B53->(dbSetOrder(1))//B53_FILIAL + B53_NUMGUI + B53_ORIMOV
	If B53->(dbSeek(B4A->(B4A_FILIAL+B4A_OPEMOV+B4A_ANOAUT+B4A_MESAUT+B4A_NUMAUT)))
		If !lAut
			B53->(Reclock("B53",.F.))
				B53->B53_STATUS := '6'
			B53->(MsUnlock())
		Else
			aAdd(aRecCan,{"B53",B53->(Recno())})		
		EndIf
	EndIf
	
	//Ponto de entrada apos tratamento padrao
	If ExistBlock("PLS09ACAN")
		ExecBlock("PLS09ACAN",.F.,.F.)
	Endif
EndIf

//Vamos informar que a guia não foi cancelada guando vier de uma requisição da TISS online
Iif(nStatusTiss != 1, nStatusTiss := 2 , "")

Return  

  /*/                                                                          
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ P09ABlank ³ Autor ³ Daher	            ³ Data ³ 18.02.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Exibir dados da autorizacao/liberacao efetuada             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
/*/
Function P09ABlank(aCols,aHeader,aVetTrab) 
LOCAL nInd	:= 0

aadd(aCols,{})

For nInd :=  1 To Len(aHeader)+1
	If nInd <= Len(aHeader)
		If     aHeader[nInd,8] == "C"
			aadd(aCols[Len(aCols)],Space(aHeader[nInd,4]))
		ElseIf aHeader[nInd,8] == "D"
			aadd(aCols[Len(aCols)],ctod(""))
		ElseIf aHeader[nInd,8] == "N"
			aadd(aCols[Len(aCols)],0)
		Else
			aadd(aCols[Len(aCols)],nInd)
		Endif
	Else
		aadd(aCols[Len(aCols)],.F.)
	Endif
Next

For nInd :=  1 To Len(aHeader)+1
	If nInd <= Len(aHeader)
		aCols[Len(aCols),nInd] := CriaVar(aHeader[nInd,2],.T.)
	Else
		aCols[Len(aCols),nInd] := .F.
	Endif
Next

aadd(aVetTrab,0)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLSVLDAUD ³ Autor ³ Thiago Guilherme    ³ Data ³ 08.02.13 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Verifica se a guia esta em análise antes da exclusão       ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function PLSVLDAUD(cAlias)

Local lApagaGuia := GetNewPar("MV_PLAUDAN",.F.) // Determina que mesmo se a guia de anexo estiver em analise de auditoria podera ser excluida

If PLSALIASEX("B53")
	If B53->(FieldPos("B53_NUMERO")) > 0
		
		DbSelectArea("B53")
		B53->(dbSetOrder(1))
   		
   		If lApagaGuia 
   			If B53->(dbSeek(xFilial("B53")+B4A->(B4A_OPEMOV+B4A_ANOAUT+B4A_MESAUT+B4A_NUMAUT)))
   				If B53->(B53_SITUAC) <> "1"
		   			//If MsgYesNo(STR0062) //"Essa Guia encontra-se em auditoria deseja excluir?")
		   			If MsgYesNo("Essa Guia encontra-se em auditoria deseja excluir?") //"Essa Guia encontra-se em auditoria deseja excluir?")
		   				Return .T.
		   			Else 
		   				Return .F.
		   			Endif	
	   			Endif
   			Endif
   		Else
			If B53->(dbSeek(xFilial("B53")+B4A->(B4A_OPEMOV+B4A_ANOAUT+B4A_MESAUT+B4A_NUMAUT)))
				If B53->B53_SITUAC == "2"
					Help("",1,"PL800VLD")
					Return .F.
				EndIf
			EndIf
		Endif
	EndIf
Endif	
Return .T.

/*/{Protheus.doc} PLB4AValid
Valid do campo IDADE

@author pls
@since 14/07/2015
@version P11
/*/
function PLB4AValid()
return (M->B4A_IDADE <> 0)

/*/{Protheus.doc} PLB4AWhen
When do campo IDADE

@author pls
@since 14/07/2015
@version P11
/*/
function PLB4AWhen()
return (!empty(M->B4A_GUIREF) .and. M->B4A_IDADE == 0)


//-------------------------------------------------------------------
/*/{Protheus.doc} PL9AInfPro 
define o arquivo de ini

@author  PLS TEAM
@version P11
@since    04.04.16
/*/
//-------------------------------------------------------------------
Function PL9AInfPro() 
Local aArea := GetArea()      
Local lInterProt := .F.     

If Empty(B4A->B4A_PROATE)           

	If GetNewPar("MV_PLSUNI","1") == "1" .And. B4A->B4A_CODEMP == GetNewPar("MV_PLSGEIN","0050")
		lInterProt := .T.    
	EndIf    
	 	
	cNumProto := Space(20)
	P773AutInc("B4A",@cNumProto,nil,lInterProt,.F.)   
		
	//Conclui um protocolo    
	If !Empty(cNumProto) .And. lInterProt
		P773AutCon("B4A",cNumProto,B4A->(B4A_OPEMOV+B4A_ANOAUT+B4A_MESAUT+B4A_NUMAUT))
	EndIf
		
	If !Empty(cNumProto)
		B4A->(RecLock("B4A",.F.))
		B4A->B4A_PROATE := cNumProto
		B4A->(MsUnLock())
		
		MsgInfo(STR0058+cNumProto)//"Protocolo registrado: "  
	EndIf	
Else
	MsgInfo(STR0059)//"O protocolo já foi registrado para este atendimento."
Endif  

RestArea(aArea)

Return


/*/
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLSA09AMTC ³ Autor ³ Renan Martins       ³ Data ³ 28.04.15 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Motivo de cancelamento do procedimento, se negado auditoria³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
/*/
Function PLSA09AMTC(cAliasEnc,oEncA,oBrwC,cTipo,oBrwP, cNumGuia, cRecno, cAliasP, lEstado, lWeb)
Local aArea := B72->(GetArea())
Local cAlias := cAliasP
Local cAlIts
Default lWeb := .F.

IF lEstado
   MsgAlert( STR0001 ) //"Procedimento em inclusão. "
   Return
ENDIF

IF (cAlias == "BEA")
   cAlIts := "BE2"
ELSEIF (cAlias == "B4A")
   cAlIts := "B4C"
ELSEIF (cAlias == "BE4")
   cAlIts := "BEJ"
ELSEIF (cAlias == "B4Q") 
	cAlIts := "BQV"
ENDIF  

B72->(DbSetOrder(4))   
IF ( B72->(MsSeek(xFilial("B72")+oBrwP:FieldGet(cAlIts+"_CODPAD")+oBrwP:FieldGet(cAlIts+"_CODPRO")+oBrwP:FieldGet(cAlIts+"_SEQUEN")+cAlias+Alltrim(Str(cRecno)) )))                                                                                    
   MsgAlert(STR0002 + CHR(13) + CHR(13) + STR0003 + B72->B72_MOTIVO + " - " + Posicione("BCT",1,xFilial("BCT")+PlsIntPad()+; 
			 B72->B72_MOTIVO,"BCT_DESCRI") + CHR(13) + CHR(13) + STR0004 + B72->B72_OBSANA) //Motivo TISS Bloqueio#Código:#Observações do Analista: 
ELSE
   MsgAlert( STR0005 ) //Procedimento não auditado ou sem críticas
ENDIF
Return

Function PLSABR90A(oProc, oCri)
oBrwPro := oProc
oBrwCri := oCri 
Return
/*/
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLSIMPRIM ³ Autor ³ Victor Alves         ³ Data ³ 08.01.21 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³Define se os campos cadastrados na B7B serão impressos ou não±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
/*/
Function PLSIMPRIM(cTp,cVerTiss,cCampo)
Local lImprim := .F.
Local cSQL	  := ""

cSQL := " SELECT B7B_IMPRIM "
cSQL += " FROM " + RetSqlName("B7B")
cSQL += " WHERE B7B_FILIAL = '"+xFilial("B7B")+"' "
cSQL += " AND B7B_TIPGUI = '"+cTp+"' "
cSQL += " AND B7B_TISVER  = '"+cVerTiss+"' "
cSQL += " AND B7B_CAMPO  = '"+cCampo+"' "
cSQL += " AND D_E_L_E_T_ = ' ' "

dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSQL),"TRB",.f.,.t.)
while TRB->(!eof())
   If TRB->B7B_IMPRIM == "S"
		lImprim := .T.
   EndIf
   Exit
enddo
TRB->(dbclosearea())

Return lImprim
