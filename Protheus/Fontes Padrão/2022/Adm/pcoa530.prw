#INCLUDE "PCOA530.ch"
#Include "PROTHEUS.CH"
#Include "AP5MAIL.CH"                           
#Include "SIGAWF.CH"

Static _aDadosBlq
Static _lLibCtg     := .F.
Static aCntgBak		:= 	{} // Backup de Contingencias
Static _nVldEmpAKD 	:=  0
Static lPcoFecBl	:= ExistBlock( "PCOFECBL" )
Static lPcoCont		:= ExistBlock( "PCOCONTG" )
Static lPco5307		:= ExistBlock( "PCOA5307" )
Static lPcoDesvc     := ExistBlock( "PCODESVC" )    

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ PCOA530  บAutor  ณMicrosiga           บ Data ณ  03/23/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ CONTROLE DE SALDO DE CONTINGENCIA                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ      
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function PCOA530(aDadosBlq,cMsgBlind)

Local cCodCubo	:= ""
Local cProcesso := ""
Local cCube		:= ""
Local nPos		:= 0
Local cChaveAtu	:= ""
Local lRet		:= .F.
Local cConta	:= ""
Local cCusto	:= ""
Local nDet		:= 0
Local lContinua := .T.

Default cMsgBlind := ""

_lLibCtg     := .F.

_aDadosBlq 	:= aClone(aDadosBlq)

// Ponto de Entrada controle saldo contingencia
If lPcoCont
	// Se retornar True, verifica o controle saldo de contingencia normalmente(segue fluxo).
	// Se retornar falso, o processo foi bloqueado e nao passara pelo controle de saldo de contingencia. 
	lContinua:= ExecBlock("PCOCONTG",.f.,.f.,{_aDadosBlq}) 
Endif

If lPcoDesvc
	lRetDes := ExecBlock("PCODESVC",.F.,.F.,{_aDadosBlq})
	If lRetDes 
       	lRet := .T.
		lContinua := .F.
	Else
		lContinua := .T.
	EndIf 
EndIf

//Somente prossegue pelo processo de contingencia normal se lContinua for .T.

If  lContinua

	If LockByName( _aDadosBlq[4], .T.  )
		
		If _aDadosBlq[3] > 0 .and. _aDadosBlq[2] <= _aDadosBlq[3]
			lRet	:=	.T.
			
		Else
			
			While .T.
				aArea	:= GetArea()
				cConta 		:= ALLTRIM(SUBSTR(_aDadosBlq[4],1,10))
				cCusto		:= ALLTRIM(SUBSTR(_aDadosBlq[4],10,10))
				cDesccta    := ""
				cDesccusto	:= ""
				
				DbSelectArea("AK8")
				DbSetOrder(1)
				DBSEEK(xFilial("AK8") + _aDadosBlq[5])//Filial + Cod.Processo
				cProcesso := AK8_DESCRI
				RestArea (aArea)
				cCodCubo := Posicione("AL4", 1, xFilial("AL4")+AKJ->AKJ_REACFG, "AL4_CONFIG")
				
				dbSelectArea("AKW")
				dbSetOrder(1)
				MsSeek(xFilial("AKW")+cCodCubo)
				
				cCube	:= ""
				nPos	:=	1
				While (!Eof()) .And. (AKW->AKW_FILIAL+AKW->AKW_COD == xFilial("AKW")+cCodCubo) .And. (AKW->AKW_NIVEL <= AKJ->AKJ_NIVPR)
					cCube += IIF(cCube<>"", " - ", "")
					cChaveAtu	:=	Substr(_aDadosBlq[4], nPos, AKW->AKW_TAMANH)
					nPos		+=	AKW->AKW_TAMANH
					If !Empty(cChaveAtu)
						cCube += Alltrim(AKW->AKW_DESCRI) +" : "+ AllTrim(cChaveAtu)
					Else
						cCube += 'Outros '
					Endif
					dbSkip()
				EndDo
				
				cTxtBlq	:=	(STR0001+; //"Os saldos atuais do Planejamento e Controle Or็amentแrio sใo insuficientes para completar esta opera็ใo no periodo de "
				DTOC(_aDadosBlq[9,1])+" - "+DTOC(_aDadosBlq[9,2])+"."+CRLF+; //###
				STR0002+AllTrim(AKJ->AKJ_DESCRI)+CRLF+; //"Tipo de Bloqueio : "
				STR0064+cProcesso+CRLF+; //"Processo : "
				STR0003+AllTrim(_aDadosBlq[8])+CRLF+; //"Cubo : "
				cCube+CRLF+;
					STR0006+ALLTRIM(Transform(_aDadosBlq[3],"@E 99,999,999,999,999.99"))+ STR0007 +ALLTRIM(Transform(_aDadosBlq[2],"@E 99,999,999,999,999.99")))+CRLF+; //"Saldo Previsto : "###" Vs Saldo Realizado : "
				STR0041+" --> "+ALLTRIM(Transform(_aDadosBlq[2]- _aDadosBlq[3],"@E 99,999,999,999,999.99"))+CRLF  //"Solicita็ใo de Conting๊ncia"
				
				If ExistBlock( "PCOA5301" )
					//P_Eฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//P_Eณ Ponto de entrada utilizado para inclusao de funcoes de usuarios na     ณ
					//P_Eณ preparacao do texto a ser exibido no email / html dados do bloqueio    ณ
					//P_Eณ Parametros : cTxtBlq                                                   ณ
					//P_Eณ Retorno    : cTxtBlq (texto manipulado)                                ณ
					//P_Eภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					cTxtBlq := ExecBlock( "PCOA5301", .F., .F.,{cTxtBlq, _aDadosBlq})
				EndIf
				
				If !IsBlind()
					nDet := Aviso(STR0008,cTxtBlq,; //"Planejamento e Controle Or็amentแrio"
					{STR0009,STR0065/*STR0010*/,STR0011},3,STR0012,,; //"&Fechar"###"&Solic. lib."###"&Detalhes"###"Saldo Insuficiente"###"Contingencia"
					"PCOLOCK")
					
					If nDet <= 1
						// Ponto de entrada que permite realizar customizacoes na acao do botao fechar
						If lPcoFecBl
							ExecBlock( "PCOFECBL", .F., .F. )
						EndIf
						Exit
						
					ElseIf (nDet == 2)
						
						lRet := A530SelCTs(cTxtBlq)
						If lRet
							
							Exit
							
						EndIf
						
					Else
						cCodCuboPrv  := Posicione("AL4", 1, xFilial("AL4")+AKJ->AKJ_PRVCFG, "AL4_CONFIG")
						cCodCuboReal := Posicione("AL4", 1, xFilial("AL4")+AKJ->AKJ_REACFG, "AL4_CONFIG")
						PcoDetBlq(cCodCuboPrv, cCodCuboReal, _aDadosBlq[9,1], _aDadosBlq[9,2], _aDadosBlq[4], _aDadosBlq[3], _aDadosBlq[2], _aDadosBlq[10])
					EndIf	
				Else
					cMsgBlind := cTxtBlq
					Exit
				EndIf
			EndDo
			
		Endif
		UnLockbyName(_aDadosBlq[4])
		
	Else
		
		aArea	:= GetArea()
		cConta 		:= ALLTRIM(SUBSTR(_aDadosBlq[4],1,10))
		cCusto		:= ALLTRIM(SUBSTR(_aDadosBlq[4],10,10))
		cDesccta    := ""
		cDesccusto	:= ""
		
		DbSelectArea("AK8")
		DbSetOrder(1)
		DBSEEK(xFilial("AK8") + _aDadosBlq[5])//Filial + Cod.Processo
		cProcesso := AK8_DESCRI
		RestArea (aArea)
		cCodCubo := Posicione("AL4", 1, xFilial("AL4")+AKJ->AKJ_REACFG, "AL4_CONFIG")
		
		dbSelectArea("AKW")
		dbSetOrder(1)
		MsSeek(xFilial("AKW")+cCodCubo)
		
		cCube	:= ""
		nPos	:=	1
		While (!Eof()) .And. (AKW->AKW_FILIAL+AKW->AKW_COD == xFilial("AKW")+cCodCubo) .And. (AKW->AKW_NIVEL <= AKJ->AKJ_NIVPR)
			cCube += IIF(cCube<>"", " - ", "")
			cChaveAtu	:=	Substr(_aDadosBlq[4], nPos, AKW->AKW_TAMANH)
			nPos		+=	AKW->AKW_TAMANH
			If !Empty(cChaveAtu)
				cCube += Alltrim(AKW->AKW_DESCRI) +" : "+ AllTrim(cChaveAtu)
			Else
				cCube += 'Outros '
			Endif
			dbSkip()
		EndDo
		
		cTxtBlq	:=	(STR0088+CRLF+; //"Existe uma solicita็ใo de contingencia em andamento para esta combina็ใo de entidades or็amentarias."
		STR0002+AllTrim(AKJ->AKJ_DESCRI)+CRLF+; //"Tipo de Bloqueio : "
		STR0064+cProcesso+CRLF+; //"Processo : "
		STR0003+AllTrim(_aDadosBlq[8])+CRLF+cCube) //"Cubo : "
		
		Aviso(STR0008,cTxtBlq,{STR0009},3,STR0012) //"Planejamento e Controle Or็amentแrio"###"&Fechar"###"Saldo Insuficiente"
		
	EndIf
Endif

// Zera o valor de empenho no final da rotina
_nVldEmpAKD := 0

// Ponto de Entrada controle saldo contingencia
If lPco5307
	lRet:= ExecBlock("PCOA5307",.f.,.f.,{lRet,_aDadosBlq,nDet}) 
Endif

Return (lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณPcoGravaCont   บAutor  ณBruno Sobieski   บ Data ณ 05/03/06  บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณGeracao de registro para solicitacao de contingencia        บฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ          ณ Adaptado em 14/11/07 por Rafael Marin para utilizar tabe็asณฑฑadmin
ฑฑณ          ณ Padroes (ZU1,ZU2,ZU3,ZU4,ZU6 -> ALI,ALJ,ALK,ALL,ALM)       ณฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function GrvContPCO(nRecAKD,cObs,aVlsCtg,oBrwALJ)
Local nX                                    
Local nRet	:= 0 
Local lCtg  // Existe contigencia com a chave aprovada
Local lRetorno	:=.F.
Local lContinua:= .T.
Local cChave	:=	''
Local cMsgPas  := ""
Local lSenha	:= SUPERGETMV("MV_PCOCTGP",.F.,.F.)
Local cChaveAKD
Local aAreaAtu,aAreaAKD
Local lCancEmail := .F.

DEFAULT cObs	:=	""
DEFAULT oBrwALJ := Nil

// Verrifica o valor da contingencia caso o mesmo tenha sido alterado no ponto de entrada PCOA50305
If aVlsCtg[1] <= 0

	lContinua := .F.

EndIf

//ษออออออออออออออออออออออออออออออออออออออออออออออออออออป
//บ Verrifica chave configurada para contingencia      บ
//บ  no cadastro de blqoueio. (AKA).                   บ
//ศออออออออออออออออออออออออออออออออออออออออออออออออออออผ
If lContinua .and. ALI->(FieldPos("ALI_CHAVE"))>0 .and. AKA->(FieldPos("AKA_CHVCTG"))>0

	cChave := Padr(&(AKA->AKA_CHVCTG),Len(ALI->ALI_CHAVE))
	DbSelectArea('ALI')
	DbSetorder(5)
	If !Empty(cChave) .And. DbSeek(xFilial('ALI')+cChave)
		nDet	:=	0
		While ALI->( !Eof() .And. ALI_FILIAL+ALI->ALI_CHAVE == xFilial("ALI")+cChave )
			DbSelectArea("ALJ")
			DbSetOrder(1)
			DbSeek(xFilial("ALJ") + ALI->ALI_CDCNTG )
			If ALI->ALI_STATUS == "02"
				cMsg		:= STR0013+UsrRetName(ALI->ALI_USER) //"A contingencia aguarda liberacao do usuario :"
				nRet		:= Aviso(STR0014,STR0066+ALJ->ALJ_CDCNTG+')'+CRLF+cMsg,{STR0067,STR0016},3) //"Solicitacao ja existe"###"Fechar"###'Ja existe solicitacao de contingencia com a chave configurada: '###"Continuar"
				lContinua	:= (nRet==1)
				Exit
			ElseIf ALI->ALI_STATUS $ "04/06"
				cMsg		:= STR0017+UsrRetName(ALI->ALI_USER) //"A contingencia foi cancelada pelo usuario :"
				nRet		:= Aviso(STR0014,STR0066+ALJ->ALJ_CDCNTG+')'+CRLF+cMsg,{STR0067,STR0016},3) //"Solicitacao ja existe"###"Fechar"###'Ja existe solicitacao de contingencia com a chave configurada: '###"Continuar"
				lContinua	:= (nRet==1)
				Exit
			Else
				DbSelectArea("ALJ")
				cChaveAKD	:= "ALJ"+&(IndexKey())
				aAreaAKD	:= AKD->(GetArea())
				DbSelectArea("AKD")
				DbSetOrder(10)
				If !DbSeek(xFilial("AKD") + cChaveAKD )
					lCtg 	:= .T.
					cMsg	:= STR0066 +ALJ->ALJ_CDCNTG+')'+CRLF //'Ja existe solicitacao de contingencia com a chave configurada: '
					cMsg	+= STR0068 //"Contingencia liberada !"
				EndIf
				RestArea(aAreaAKD)
			Endif								
			DbSelectArea("ALI")
			ALI->(DbSkip())
		Enddo		
		// Tem Contingecia aprovada com a Chave de contingencia
		If lCtg
			nRet		:= Aviso(STR0014,cMsg,{STR0067,STR0016},3) //"Solicitacao ja existe"###'Ja existe solicitacao de contingencia para este pedido e item (Solicitacao '###"Fechar"###"Continuar"
			lContinua	:= (nRet==1)
		EndIf
	Endif

EndIf

//P_Eฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//P_Eณ Ponto de Entrada para validar a Inclusao de contignecias duplicadas    ณ
//P_Eณ Parametros :                                                           ณ
//P_Eณ     Pramixb[1] = Chave da contignecia na tabela ALI                    |
//P_Eณ Retorno    : Array com os seguintes elementos                          ณ
//P_Eณ     Elemento 1: Valor da Contingencia.                                 ณ
//P_Eณ     Elemento 2: Valor do Empenho da contingencia                       ณ
//P_Eณ  Ex. :  User Function PCOA5306                                         ณ
//P_Eณ              cChaveALI := Paramixb[1]                                  ณ
//P_Eณ              // Regra do Cliente                                       |
//P_Eณ         Return .T. //Libera a inclusao da contigencia                  ณ
//P_Eภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

If nRet==1 .and. ExistBlock( "PCOA5306" )
	lContinua := ExecBlock("PCOA5306",.F.,.F.,{ cChave } )
	If Valtype(lContinua)<>"L"
		lContinua := .F.
	EndIf
EndIf

If lContinua
	lRetorno	:=	PCOA530ALC(1,AKJ->AKJ_COD,{_aDadosBlq[5],_aDadosBlq[2],_aDadosBlq[3],_aDadosBlq[1],_aDadosBlq[4],AKD->(AKD_LOTE+AKD_ID),cObs},,,@lCancEmail)

	If lRetorno

		RecLock('ALJ',.T.)
		For nX := 1 To (AKD->(FCount()))
			nPosCpo := ALJ->(FieldPos("ALJ_"+Substr(AKD->(FieldName(nX)),5))) 
			If nPosCpo > 0
				ALJ->(FieldPut(nPosCpo,AKD->(FieldGet(nX))) )
			Endif
		Next nX
		ALJ_FILIAL 	:= xFilial('ALJ')
		ALJ_ID		:=	StrZero(1,TamSX3('ALJ_ID' )[1])		
		ALJ_CDCNTG	:=	ALI->ALI_CDCNTG       
		ALJ_LOTEID	:=	AKD->(AKD_LOTE+AKD_ID)
		ALJ_TPSALDO	:=	"CT" //LANCANDO EM SALDO DE CONTINGENCIA
		ALJ_VALOR1	:=	aVlsCtg[1]//_aDadosBlq[2]-_aDadosBlq[3]
		MsUnLock()

		If lSenha
			DbSelectArea("ALJ")
			DbSetOrder(1)
			DbSeek(xFilial("ALJ") + ALI->ALI_CDCNTG )
			cMsgPas := CRLF + STR0069 + PcoCtngKey() //"A senha para utiliza็ใo da contingencia ้:"
	
		EndIf
	
		Aviso(STR0070, STR0071 + ALI->ALI_CDCNTG + STR0072 + cMsgPas,{STR0016},3) //"Fechar"###"Contingencia solicitada!"###"A contingencia "###" foi gerada com sucesso aguarde aprova็ใo."        

		//ษอออออออออออออออออออออออออออออออออออออออออออป
		//บ Lan็amento de Empenho de Contingencia     บ
		//ศอออออออออออออออออออออออออออออออออออออออออออผ
		If ALJ->(FieldPos("ALJ_EMPVAL"))>0		
			
			RecLock('ALJ',.F.)
			ALJ_EMPVAL	:=  aVlsCtg[2]//(AKD->AKD_VALOR1 - _nVldEmpAKD) - ALJ_VALOR1
			MsUnLock()

			// Grava Area Atual
			aAreaAtu := GetArea()
			aAreaAKD := AKD->(GetArea())
			// Inicia lan็amento para Empenho de saldo na contingencia
			PcoIniLan("000356",.F.)
			PcoDetLan("000356","02","PCOA530")
			PcoFinLan("000356",,,.F.)

			RestArea(aAreaAKD)
			RestArea(aAreaAtu)
	
		EndIf
		
		If ExistBlock("PCOA5303")

			//P_Eฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//P_Eณ Ponto de entrada utilizado apos a criacao da tabela ALJ. Utilizado     ณ
			//P_Eณ para manipula็ใo de campos customizados.                               ณ
			//P_Eณ Parametros : Nenhum                                                    ณ
			//P_Eณ Retorno    : Nenhum                                                    ณ
			//P_Eณ  Ex. :  User Function PCOA5303                                         ณ
			//P_Eณ         Return                                                         ณ
			//P_Eภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		
			ExecBlock("PCOA5303",.F.,.F.)
		
		EndIf
			
	Else
		if lCancEmail
			Aviso(STR0018, STR0114 + CRLF + STR0115,{"OK"})//"Aten็ใo","Opera็ใo cancelada ou Erro no envio do email! Nใo gerada a solicita็ใo de conting๊ncia."
		else
			Aviso(STR0018,STR0019,{"Ok"}) //"Atencao"###"Nao existe aprovador cadastrado para liberacao deste bloqueio (tipo de bloqueio, chave e valores)."
		endIf
	Endif	
Endif

If oBrwALJ <> Nil .And. lRetorno
	aAdd( oBrwALJ:aArray , { .F. , ALJ->ALJ_CDCNTG ,ALI->ALI_NOMSOL ,ALI->ALI_DTSOLI   , ALI->ALI_DTLIB , ALJ->ALJ_VALOR1 , ALJ->ALJ_EMPVAL , 0 , {} } )
	oBrwALJ:nAt := Len(oBrwALJ:aArray)
	oBrwALJ:Refresh()
EndIf

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณPCOA530ALCณ Autor ณ Bruno Sobieski        ณ Data ณ05.03.2006ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Controla a Alcada dos bloqueios  no PCO.                   ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ PCOA530ALC(ExpN1,EXPC1,ExpA1      )                        ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ          ณ ExpN1 = Operacao a ser executada                           ณฑฑ
ฑฑณ          ณ       1 = Inclusao do documento                            ณฑฑ
ฑฑณ          ณ       2 = Transferencia para Superior                      ณฑฑ
ฑฑณ          ณ       3 = Exclusao do documento                            ณฑฑ
ฑฑณ          ณ       4 = Aprovacao do documento                           ณฑฑ
ฑฑณ          ณ       5 = Estorno da Aprovacao                             ณฑฑ
ฑฑณ          ณ       6 = Bloqueio Manual da Aprovacao                     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ Generico                                                   ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PCOA530ALC(nOper, cCodBlq, aDados, lWF, cUser,lCancEmail)

Local lFirstNiv	:= .T.
Local cAuxNivel	:= ""
Local cNextNiv	:= ""
Local cNivIgual	:= "" 
Local lRetorno	:= .F.
Local lAchou	:= .F.
Local cCodCntg	:=	""
Local cProcesso
Local nValVerba
Local nValReal
Local nValOrc
Local nMoeda
Local cChaveBlq
Local aChaveBlq	:= {}
Local cLoteID
Local cObs		
Local cStatusAnt	:= ""
Local aRecALI		:= {}                             
Local cMensagem	:= ""
Local nX
Local lEmail		:= (SuperGetMV("MV_PCOEMCT",.F.,.T.))
Local nTipoWF		:= (SuperGetMV("MV_PCOWFCT", , 0))
Local lUseWF		:= IIf( nTipoWF != 0, .T., .F.)
Local nDiasVct	:= (SuperGetMV("MV_PCOVENC",.F.,1))
Local lCancAll	:= (SuperGetMV("MV_PCOCTCA",.F.,'2') == "1" )
Local aEmail		:= {}
Local aWFDados	:= {}                            
Local aRecAux
Local lDelEmp		:= .F.
Local lP530EWF	:= ExistBlock("P530EWF")
Local cWFID
Local cCdUsrF
Local lNewProc := .F.
DEFAULT lWF		:= .F.
DEFAULT cUser		:= __cUserID

If nOper == 1  //Inclusao do Documento
	cProcesso	:=	aDados[1]
	nValReal	:=	aDados[2]
	nValOrc	:=	aDados[3]
	nMoeda		:=	aDados[4]
	cChaveBlq	:=	aDados[5]
	cLoteID	:=	aDados[6]
	cObs		:=	aDados[7]
	
	dbSelectArea("ALM")	// Grupos de Aprovacao
	dbSetOrder(1)                             
	
	If !Empty(cCodBlq) .And. dbSeek(xFilial("ALM")+cCodBlq) 
		ALI->(dbSetOrder(2))
		If ALI->( MsSeek(xFilial("ALM")+cLoteID) ) .AND. ( ALI->ALI_STATUS <> '03' )
			cCodCntg	:=	GetSXENum('ALI','ALI_CDCNTG')
			ConFirmSX8()
		Endif	
		
		While !Eof() .And. xFilial("ALM")+cCodBlq == ALM->(ALM_FILIAL+ALM_COD) //.And. ALM_ATIVO == "1"
			nValVerba	:= nValReal - nValOrc
			nPercVerba	:= ((nValReal - nValOrc) / nValOrc)  * 100
			aChaveBlq	:= StrToCub(cChaveBlq, Posicione("AL4", 1, xFilial("AL4")+AKJ->AKJ_REACFG, "AL4_CONFIG"))
			
			If !MaAlcPcoLim(nValVerba,nPercVerba,nMoeda,cCodBlq,aChaveBlq,ALM->ALM_USER)
				dbSelectArea("ALM")
				dbSkip()
				Loop
			EndIf

			If lFirstNiv
				cAuxNivel := ALM->ALM_NIVEL
				lFirstNiv := .F.
			EndIf     

			If Empty(cCodCntg)
				cCodCntg	:=	GetSXENum('ALI','ALI_CDCNTG')
				ConFirmSX8()
			Endif	
			
			
			lNewProc := .T.			
			Reclock("ALI",.T.)
			ALI->ALI_FILIAL	:=	xFilial("ALI")
			ALI->ALI_CDCNTG	:=	cCodCntg
			ALI->ALI_CODBLQ	:=	cCodBlq
			ALI->ALI_PROCES	:=	cProcesso
			ALI->ALI_LOTEID	:=	cLoteID
			ALI->ALI_MEMO  	:=	cOBS   
			ALI->ALI_NIVEL	:=	ALM->ALM_NIVEL
			ALI->ALI_USER		:=	ALM->ALM_USER
			ALI->ALI_NOME		:=  UsrRetName(ALM->ALM_USER)
			ALI->ALI_STATUS	:=	IIF(ALM->ALM_NIVEL == cAuxNivel,"02","01")
			ALI->ALI_DTVALI	:=	dDataBase+nDiasVct
			ALI->ALI_DTSOLI	:=	MsDate()
			ALI->ALI_HORA		:=	Time()
			ALI->ALI_SOLIC	:=	__cUserID
			ALI->ALI_NOMSOL	:=	UsrRetName(__cUserID)
			// Controle de Contingencia por Chave configuravel
			If ALI->(FieldPos("ALI_CHAVE"))>0 .and. AKA->(FieldPos("AKA_CHVCTG"))>0	
				ALI->ALI_CHAVE := &(AKA->AKA_CHVCTG)			
			EndIf
			ALI->ALI_IDALI	:= FWUUIDV4()
			MsUnlock()

			If ExistBlock("PCOA5304")
				//P_Eฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//P_Eณ Ponto de entrada utilizado apos a criacao da tabela ALI. Utilizado     ณ
				//P_Eณ para manipula็ใo de campos customizados.                               ณ
				//P_Eณ Parametros : Nenhum                                                    ณ
				//P_Eณ Retorno    : Nenhum                                                    ณ
				//P_Eณ  Ex. :  User Function PCOA5304                                         ณ
				//P_Eณ         Return                                                         ณ
				//P_Eภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				ExecBlock("PCOA5304",.F.,.F.)
			EndIf
			
			AAdd(aRecALI,ALI->(Recno()))
			
			If ALI_STATUS == "02" 
				If lEmail
					AAdd(aEmail,UsrRetMail(ALM->ALM_USER))
				EndIf	
				If lUseWF     
					AAdd(aWFDados, {UsrRetMail(ALM->ALM_USER)	, ;
									ALI->ALI_FILIAL	, ;	
									ALI->ALI_CDCNTG	, ;
									ALI->ALI_CODBLQ	, ;
									ALI->ALI_PROCES	, ;
									ALI->ALI_LOTEID	, ;
									cOBS				, ;
									ALI->ALI_USER		, ;
									ALI->ALI_DTVALI	, ;
									ALI->ALI_DTSOLI	, ;
									ALI->ALI_HORA 	, ;
									ALI->ALI_SOLIC 	, ;
									ALI->ALI_NOMSOL	, ;
									ALI->(Recno())	, ;
									ALI->ALI_IDALI	})
				EndIf
			Endif                                    
			
			dbSelectArea("ALM")
			dbSkip()
			
			lRetorno	:=	.T.
		EndDo
		cMensagem:= STR0020 +CRLF+CRLF //"Solicito liberacao de verba orcamentaria para os dados abaixo. "
		cMensagem+= STR0021 +CRLF+CRLF //" Atenciosamente,"
		cMensagem+= "        "+UsrRetName() +CRLF
		cMensagem+= "        "+UsrRetMail(__cUserID) +CRLF   
	EndIf                               

ElseIf nOper	==	 4 //Liberacao
	dbSelectArea("ALM")
	dbSetOrder(2)
	dbSeek(xFilial("ALM")+ALI->ALI_CODBLQ+cUser)
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Libera a verba pelo aprovador.                      ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	dbSelectArea("ALI")
	cAuxNivel	:=	ALI_NIVEL
	cCodCntg	:=	ALI_CDCNTG

	Reclock("ALI",.F.)
	ALI_STATUS  := "03"  // Liberado
	ALI_DTLIB	:= MsDate()
	ALI_HORAL	:= Time()
	If lWF
		ALI_USRLIB	:= cUser
		ALI_NOMLIB	:=	UsrRetName(cUser)	
	Else 
		ALI_USRLIB	:= __cUserID
		ALI_NOMLIB	:=	UsrRetName(__cUserID)
	EndIf
	If Empty(ALI_IDALI)
		ALI_IDALI	:= FWUUIDV4()
	EndIf
	
	MsUnlock()
	nRec := Recno()

	If !Empty(ALI_PROCWF) .AND. !lWF
		cCdUsrF := FWWFColleagueId( ALI_USRLIB )
		If !Empty(cCdUsrF)
			CancelProcess(VAL(ALI_PROCWF), cCdUsrF, STR0093) //"Liberado atrav้s do sistema."
		EndIf
	EndIf
	
	dbSelectArea("ALI")
	DbSetOrder(1)
	dbSeek(xFilial("ALI")+cCodCntg)

	aRecAux := {}
	While !Eof() .And. xFilial("ALI")+cCodCntg == ALI_FILIAL+ALI_CDCNTG 
		If nRec == Recno()
			DbSkip()
			Loop
		Endif
		aAdd(aRecAux, { ALI->(Recno()), ALI->ALI_NIVEL } )
		dbSkip()
	EndDo
	
	aSort(aRecAux,,, { |x, y| x[2] < y[2] })

	For nX := 1 TO Len(aRecAux)
	
		dbSelectArea("ALI")
		dbGoto(aRecAux[nX,1])
	
		If cAuxNivel == ALI_NIVEL .And. ALI_STATUS != "03" .And. ALM->ALM_TPLIB$"1" //Usuario
			Exit
		EndIf
		
		If cAuxNivel == ALI_NIVEL .And. ALI_STATUS != "03" .And. ALM->ALM_TPLIB$"2" //Nivel
			Reclock("ALI",.F.)
			ALI_STATUS	:= "05"
			ALI_DTLIB	:= MsDate()
			ALI_HORAL	:= Time()
			If lWF
				ALI_USRLIB	:= cUser
				ALI_NOMLIB	:=	UsrRetName(cUser)	
			Else 
				ALI_USRLIB	:= __cUserID
				ALI_NOMLIB	:=	UsrRetName(__cUserID)
			EndIf			
			If Empty(ALI_IDALI)
				ALI_IDALI	:= FWUUIDV4()
			EndIf

			MsUnlock()

			If !Empty(ALI_PROCWF) .AND. !lWF
				cCdUsrF := FWWFColleagueId( ALI_USRLIB )
				If !Empty(cCdUsrF)
					CancelProcess(VAL(ALI_PROCWF), cCdUsrF, STR0094) //"Liberado por outro usuแrio."
				EndIf
			EndIf

		EndIf
		
		If ALI_NIVEL > cAuxNivel .And. ALI_STATUS != "03" .And. !lAchou
			lAchou := .T.
			cNextNiv := ALI_NIVEL
		EndIf
		
		If lAchou .And. ALI_NIVEL == cNextNiv .And. ALI_STATUS != "03"
			Reclock("ALI",.F.)
			ALI_STATUS :=	If(( Empty(cNivIgual) .Or. cNivIgual == ALI_NIVEL ) .And. cStatusAnt <> "01" ,"02",ALI_STATUS)
			If ALI_STATUS == "05"
				ALI_DTLIB	:= MsDate()
				ALI_HORAL	:= Time()
				
				If lWF
					ALI_USRLIB	:= cUser
					ALI_NOMLIB	:=	UsrRetName(cUser)	
				Else 
					ALI_USRLIB	:= __cUserID
					ALI_NOMLIB	:=	UsrRetName(__cUserID)
				EndIf
				If Empty(ALI_IDALI)
					ALI_IDALI	:= FWUUIDV4()
				EndIf
				
				MsUnlock()
				
				If !Empty(ALI_PROCWF) .AND. !lWF
					cCdUsrF := FWWFColleagueId( ALI_USRLIB )
					If !Empty(cCdUsrF)
						CancelProcess(VAL(ALI_PROCWF), cCdUsrF, STR0094) //"Liberado por outro usuแrio."
					EndIf
				EndIf
			EndIf
			
			  
			If ALI_STATUS == "02"
				cObs	:=	ALI->ALI_MEMO
				If lEmail .And. AllTrim(UsrRetMail(ALI->ALI_USER)) <> ""
					AAdd(aEmail,UsrRetMail(ALI->ALI_USER))
				EndIf
				If lUseWF     
					AAdd(aWFDados, {UsrRetMail(ALI->ALI_USER)	, ;
									ALI->ALI_FILIAL	, ;
									ALI->ALI_CDCNTG	, ;
									ALI->ALI_CODBLQ	, ;
									ALI->ALI_PROCES	, ;
									ALI->ALI_LOTEID	, ;
									cOBS				, ;
									ALI->ALI_USER		, ;
									ALI->ALI_DTVALI	, ;
									ALI->ALI_DTSOLI	, ;
									ALI->ALI_HORA 	, ;
									ALI->ALI_SOLIC 	, ;
									ALI->ALI_NOMSOL 	, ;
									ALI->(Recno())	, ;
									ALI->ALI_IDALI	})
				EndIf
			Endif
			cNivIgual := ALI_NIVEL					
			lAchou    := .F.
		Endif
		cStatusAnt := ALI->ALI_STATUS

	Next // nX
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Reposiciona e verifica se ja esta totalmente liberado.       ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	lRetorno	:=	.T.
	dbSeek(xFilial("ALI")+cCodCntg)
	While !Eof() .And. xFilial("ALI")+cCodCntg == ALI_FILIAL+ALI_CDCNTG
		If ALI_STATUS != "03" .And. ALI_STATUS != "05"
			lRetorno := .F.
		EndIf                  
		cSolic	:=	ALI->ALI_SOLIC
		dbSkip()
	EndDo
	If lRetorno                       
		If lEmail .And. AllTrim(UsrRetMail(cSolic)) <> ""
			AAdd(aEmail,UsrRetMail(cSolic))
			cObs	:=	""
			cMensagem	:=	STR0022+" "+cCodCntg+" "+STR0058 //"Solicitacao de liberacao orcamentaria " //" aprovada."
			DbSelectArea("ALJ")
			DbSetOrder(1)
			DbSeek(xFilial("ALJ") + cCodCntg )
			cMensagem += CRLF + STR0069 + PcoCtngKey() //"A senha para utiliza็ใo da contingencia ้:"
		EndIf
	Endif
ElseIf nOper == 6  //Cancelamento
	
	lDelEmp	 := .T. // Ativa dele็ใo do Empenho
	
	dbSelectArea("ALM")
	dbSetOrder(2)
	dbSeek(xFilial("ALM")+ALI->ALI_CODBLQ+cUser)
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Libera a verba pelo aprovador.                      ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	dbSelectArea("ALI")
	cAuxNivel	:=	ALI_NIVEL
	cCodCntg	:=	ALI_CDCNTG
	cWFID		:=	ALI_PROCWF
	Reclock("ALI",.F.)
	ALI_STATUS  := "04"  // Cancelado
	ALI_DTLIB	:= MsDate()
	ALI_HORAL	:= Time()
	If lWF
		ALI_USRLIB	:= cUser
		ALI_NOMLIB	:=	UsrRetName(cUser)	
	Else 
		ALI_USRLIB	:= __cUserID
		ALI_NOMLIB	:=	UsrRetName(__cUserID)
	EndIf
	If Empty(ALI_IDALI)
		ALI_IDALI	:= FWUUIDV4()
	EndIf  

	MsUnlock()
	nRec := Recno()

	If !Empty(ALI_PROCWF) .AND. !lWF
		cCdUsrF := FWWFColleagueId( ALI_USRLIB )
		If !Empty(cCdUsrF)
			CancelProcess(VAL(ALI_PROCWF), cCdUsrF, STR0095) //"Cancelado atrav้s do sistema."
		EndIf
	EndIf
	

	aRecAux	:= GetAlcCtg(cCodCntg)
	dbSelectArea("ALI")	

	For nX := 1 to Len(aRecAux)
		DbGoTo(aRecAux[nX,1])
		If nRec == Recno()
			Loop
		Endif

		//**************************
		// Cancela todos os niveis *
		//**************************
		If lCancAll
			Reclock("ALI",.F.)
			ALI_STATUS	:= "06"
			ALI_DTLIB	:= MsDate()
			ALI_HORAL	:= Time()

			If lWF
				ALI_USRLIB	:= cUser
				ALI_NOMLIB	:=	UsrRetName(cUser)	
			Else 
				ALI_USRLIB	:= __cUserID
				ALI_NOMLIB	:=	UsrRetName(__cUserID)
			EndIf
			
			If Empty(ALI_IDALI)
				ALI_IDALI	:= FWUUIDV4()
			EndIf

			MsUnlock()
			
			If !Empty(ALI_PROCWF) .AND. !lWF
				cCdUsrF := FWWFColleagueId( ALI_USRLIB )
				If !Empty(cCdUsrF)
					CancelProcess(VAL(ALI_PROCWF), cCdUsrF, STR0095) //"Cancelado atrav้s do sistema."
				EndIf
			EndIf

		Else
			/************  CANCELA TODOS MESMO SE TIPO DE LIBERACAO FOR USUARIO  *************/
			If cAuxNivel == ALI_NIVEL .And. ALI_STATUS != "04" /*.And. ALM->ALM_TPLIB$"2" //Nivel*/
				Reclock("ALI",.F.)
				ALI_STATUS	:= "06"
				ALI_DTLIB	:= MsDate()
				ALI_HORAL	:= Time()
	
				If lWF
					ALI_USRLIB	:= cUser
					ALI_NOMLIB	:=	UsrRetName(cUser)	
				Else 
					ALI_USRLIB	:= __cUserID
					ALI_NOMLIB	:=	UsrRetName(__cUserID)
				EndIf
				
				If Empty(ALI_IDALI)
					ALI_IDALI	:= FWUUIDV4()
				EndIf

				MsUnlock()
				
				If !Empty(ALI_PROCWF) .AND. !lWF
					cCdUsrF := FWWFColleagueId( ALI_USRLIB )
					If !Empty(cCdUsrF)
						CancelProcess(VAL(ALI_PROCWF), cCdUsrF, STR0096) //"Cancelado por outro usuแrio."
					EndIf
				EndIf

			EndIf
			
			If ALI_NIVEL > cAuxNivel .And. ALI_STATUS != "04" .And. !lAchou
				lAchou := .T.
				cNextNiv := ALI_NIVEL
				lDelEmp	 := .F. // Cancela dele็ใo do Empenho
			EndIf
			
			If lAchou .And. ALI_NIVEL == cNextNiv .And. ALI_STATUS != "04"
				Reclock("ALI",.F.)
				
				ALI_STATUS :=	If(( Empty(cNivIgual) .Or. cNivIgual == ALI_NIVEL ) .And. cStatusAnt <> "01" ,"02",ALI_STATUS)
				
				If ALI_STATUS == "06"
					ALI_DTLIB	:= MsDate()
					ALI_HORAL	:= Time()
					
					If lWF
						ALI_USRLIB	:= cUser
						ALI_NOMLIB	:=	UsrRetName(cUser)	
					Else 
						ALI_USRLIB	:= __cUserID
						ALI_NOMLIB	:=	UsrRetName(__cUserID)
					EndIf
					If Empty(ALI_IDALI)
						ALI_IDALI	:= FWUUIDV4()
					EndIf

					MsUnlock()

					If !Empty(ALI_PROCWF) .AND. !lWF
						cCdUsrF := FWWFColleagueId( ALI_USRLIB )
						If !Empty(cCdUsrF)
							CancelProcess(VAL(ALI_PROCWF), cCdUsrF, STR0096) //"Cancelado por outro usuแrio."
						EndIf
					EndIf

				EndIf
				
				If ALI_STATUS == "02"
					If lEmail .And. ALLTRIM(UsrRetMail(ALI->ALI_SOLIC)) <> ""
						AAdd(aEmail,UsrRetMail(ALI->ALI_SOLIC))
					EndIf
				Endif
				cNivIgual := ALI_NIVEL					
				lAchou    := .F.
			Endif
			cStatusAnt := ALI->ALI_STATUS
		EndIf
	Next
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Reposiciona e verifica se ja esta totalmente liberado.       ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	lRetorno	:=	.T.
	dbSeek(xFilial("ALI")+cCodCntg)
	While !Eof() .And. xFilial("ALI")+cCodCntg == ALI_FILIAL+ALI_CDCNTG
		If ALI_STATUS != "04" .And. ALI_STATUS != "06"
			lRetorno := .F.
		EndIf                  
		cSolic	:=	ALI->ALI_SOLIC
		dbSkip()
	EndDo
	If lRetorno                       
		If (lEmail.or.lUseWF) .And. Alltrim(UsrRetMail(cSolic)) <> ""
			AAdd(aEmail,UsrRetMail(cSolic))
			cObs	:=	""
			cMensagem	:=	STR0017+UsrRetName(__cUserID) //"A contingencia foi cancelada pelo usuario :"
		EndIf
	Endif
	If lDelEmp // Estorna lana็emnto de Empenho

		DbSelectArea("ALJ")
		DbSetOrder(1)
		DbSeek(xFilial("ALJ") + cCodCntg )	
		
		PcoIniLan("000356",.F.)
		PcoDetLan("000356","02","PCOA530",.T.)
		PcoFinLan("000356",,,.F.)

	EndIf
EndIf               
               
CONOUT(STR0024+alltrim(STR(LEN(aWFDados)))+")") //"Verificando Tipo de Confirma็ใo de Solicita็ใo (WF:"
If lP530EWF
	ExecBLock ("P530EWF",.F.,.F.,{aWFDados,aEmail,cOBS,cMensagem})
Else
	If(!FWIsInCallStack("PCO530_001"))
		If (LEN(aWFDados)>0)
			For nX := 1 To Len(aWFDados)
				PCOWFCT(aWFDados[nX], nTipoWF)
			Next nX
		Else                        
			For nX := 1 To Len(aEmail)
				If !(EmailBlq(aEmail[nX],.T.,cOBS,cMensagem, lWF))
					If lNewProc
						Reclock("ALI", .F.)
						ALI->(DbDelete())
						ALI->(MsUnlock())
						lRetorno := .F.
						
					EndIF
					lCancEmail := .T.
				EndIf
			Next
		EndIf
	EndIf
EndIf

dbSelectArea("ALI")

Return lRetorno


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณMaAlcPcoLim    บAutor  ณBruno Sobieski   บ Data ณ 05/03/06  บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณEncontra Limite do Aprovador da Solicitacao de compras      บฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ          ณ Adaptado em 14/11/07 por Rafael Marin para utilizar tabe็asณฑฑ
ฑฑณ          ณ Padroes (ZU1,ZU2,ZU3,ZU4,ZU6 -> ALI,ALJ,ALK,ALL,ALM)       ณฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function MaAlcPcoLim(nValVerba,nPercVerba,nMoeda,cCodBlq,aChaveBlq,cUser)
Local lRet		:=	.F.
Local cQuery	:=	""
Local nX

cQuery	:=	" SELECT ALK_USER FROM "+RetSqlName("ALL")+ " ALL1, "+RetSqlName("ALK")+" ALK" 
cQuery	+=	" WHERE ALK_FILIAL = '"+xFilial('ALK')+"' AND " 
cQuery	+=	" ALL_FILIAL = '"+xFilial('ALK')+"' AND  "
cQuery	+=	" ALK_STATUS = '1' AND "
cQuery	+=	" ALL_CODBLQ='"+cCodBlq+"' AND "
cQuery	+=	" ALL_USER=ALK_USER AND  "
cQuery	+=	" ALL_USER='"+cUser+"' AND "
cQuery	+=	" ALL_MOEDA = "+Str(nMoeda)+ " AND "

For nX:= 1 To Len(aChaveBlq)
	cQuery	+=	" SubString(ALL_CODINI," + Alltrim(Str(aChaveBlq[nX,2])) + "," + Alltrim(Str(aChaveBlq[nX,3])) + ") <= '" + aChaveBlq[nX,1] + "' AND "
	cQuery	+=	" SubString(ALL_CODFIM," + Alltrim(Str(aChaveBlq[nX,2])) + "," + Alltrim(Str(aChaveBlq[nX,3])) + ") >= '" + aChaveBlq[nX,1] + "' AND"
Next

cQuery	+=	" (( ALL_TPMIN = '1' AND "+Str(nValVerba)+ " BETWEEN ALL_MINIMO AND ALL_MAXIMO)    OR "
cQuery	+=	"  ( ALL_TPMIN = '2' AND "+Str(nPercVerba)+ " BETWEEN ALL_MINIMO AND ALL_MAXIMO) ) AND "
cQuery	+=	" ALL1.D_E_L_E_T_= ' ' AND "
cQuery	+=	" ALK.D_E_L_E_T_ = ' ' "
cQuery	:=	ChangeQuery(cQuery) 

dbUseArea( .T., "TopConn", TCGenQry(,,cQuery),"QRYTRB", .F., .F. )
If !Eof()
	lRet	:=	.T.
Endif
DbCloseArea()

Return lRet                                                           

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ   EMAILBLQ    บAutor  ณBruno Sobieski   บ Data ณ 05/03/06  บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Envia email de bloqueio para aprovador da solicitacao      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function EMAILBLQ(cMail,lEditaTxt,cTxtBlq,cMensagem, lWF) 
Local cTO	:= Padr(cMail,200)
Local cCC	:= SPACE(200)
Local cAssunto	:=	Padr(STR0025,200) //"Solicitacao de liberacao orcamentaria"
Local oDLg                                                                                    
Local cMailConta	:=SUPERGETMV("MV_RELACNT",.F.,"")
Local cMailServer	:=SUPERGETMV("MV_RELSERV",.F.,"")
Local cMailSenha	:=SUPERGETMV("MV_RELPSW",.F.,"")
Local lDlgOk
Local cMsg5302
Local lRelauth  := SuperGetMv("MV_RELAUTH",, .F.)
Local cMailAuth
DEFAULT cTxtBLQ	:=	""
DEFAULT lWF		:=	.F.

lDlgOk	:= lWF // Caso seja aprova็ใo por workflow for็a ok do Dialog

Private cError  := ""
Private lOk    	:=	.F.
Private lSendOk	:=	.T.  

lMudaEmail 	:=	Empty(cMail)

If !EMPTY(cTxtBlq)
	cMensagem	+=	STR0026+CRLF+CRLF //"_Dados do bloqueio____________________"
	cMensagem	+=	cTxtBlq
Endif

If ExistBlock("PCOA5302")

	//P_Eฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//P_Eณ Ponto de entrada utilizado alterar o texto envaido no email informado  ณ
	//P_Eณ que a contingencia foi aprovada.                                       ณ
	//P_Eณ Parametros : Nenhum                                                    ณ
	//P_Eณ Retorno    : Caracter (Texto a ser enviado no email)                   ณ
	//P_Eณ  Ex. :  User Function PCOA5302                                         ณ
	//P_Eณ         Return ( " Contingencia aprovada " )                           ณ
	//P_Eภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

	cMsg5302	:= ExecBlock("PCOA5302",.F.,.F.,{cMensagem})
	cMensagem 	:= If(VALTYPE(cMsg5302)="C",cMsg5302,cMensagem)

EndIf

If lEditaTXT .And. !lWF
	DEFINE MSDIALOG oDLg from 110,013 To 539,696 Title OemToAnsi(STR0027) PIXEL of oMainWnd //"Envio de email"
	@ 002,002 To 50,334 PIXEL of oDlg
	@ 009,006 Say OemToAnsi(STR0028)	Size 32,8		PIXEL of oDlg	//"Para"
	@ 022,006 Say OemToAnsi(STR0029) 	Size 29,8		PIXEL of oDlg	//"Com copia"
	@ 035,006 Say OemToAnsi(STR0030) 	Size 33,8		PIXEL of oDlg	//"Assunto"
	@ 009,039 MSGet cTo 					Size 294,10	PIXEL of oDlg
	@ 022,039 MSGet cCC 					Size 294,10	PIXEL of oDlg
	@ 035,039 MSGet cAssunto 			Size 294,10	PIXEL of oDlg
	@ 052,003 Get cMensagem MEMO 		Size 332,142	PIXEL of oDlg

	@ 196,240 Button OemToAnsi(STR0092) Size 36,16 Action (lDlgOk := .F. ,oDlg:End()) PIXEL of oDlg //"&Cancelar"
	@ 196,299 Button OemToAnsi(STR0031) Size 36,16 Action (lDlgOk := .T. ,oDlg:End()) PIXEL of oDlg //"&Enviar"
	Activate Dialog oDlg
	cMensagem+=	"______________________________________"+CRLF
Endif                     

If lDlgOk
	If !Empty(cMailServer) 
		// Conecta uma vez com o servidor de e-mails
		CONNECT SMTP SERVER cMailServer ACCOUNT cMailConta PASSWORD cMailSenha RESULT lOk
	    If lOk
			If lRelauth
				If ( nPosArroba := At("@", cMailConta) ) > 0 
					cMailAuth := Alltrim(Subs(cMailConta,1,nPosArroba-1))
				Else
					cMailAuth := Alltrim(cMailConta)
				EndIf
				lOk := Mailauth( cMailAuth, cMailSenha )
				If !lOk // valida็ใo para quando for necessario o dominio na autentica็ใo
					lOk := Mailauth( cMailConta, cMailSenha )
				Endif
			Else
				lOk := .T.
			Endif
		EndIf
		If lOk
			SEND MAIL FROM cMailConta/*UsrRetMail(__cUserID)*/ To cTo BCC cCC  SUBJECT cAssunto BODY cMensagem  RESULT lSendOk
			If !lSendOk
				//Erro no Envio do e-mail
				lOk :=.F.
				GET MAIL ERROR cError                                
				If !lWF .and. !Empty(cError) 
					Aviso(STR0032,cError,{STR0016},2)  //"Erro no envio do e-Mail"###"Fechar"
				EndIf
			EndIf
		Else
			//Erro na conexao com o SMTP Server
			If !Empty(cMailServer) 
				GET MAIL ERROR cError
			Endif
			If !lWF .and. !Empty(cError) 
				Aviso(STR0032,cError,{STR0016},2)  //"Erro no envio do e-Mail"###"Fechar"
			EndIf	
		EndIf
		//se conseguiu conexใo, disconecta do server
		If lOk
			DISCONNECT SMTP SERVER
		else
			lDlgOk := .F.
		EndIF
	else
		lDlgOk := .F.	
	EndIf
	if !lDlgOk	
		lDlgOk := MsgNoYes(STR0116,STR0032)//Email nใo enviado, deseja gerar a Conting๊ncia ? 
	EndIf		
EndIf

Return lDlgOk


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOWFCT   บAutor  ณRafael Marin        บ Data ณ  13/11/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Prepara workflow para envio a aprovadores de Contingencia  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function PCOWFCT(aWFDados, nTipoWF) 
Local aArea	:= GetArea()
Local oHtml	:= NIL			//Objeto utilizado para montar o E-Mail
Local oP		:= NIL			//Objeto utilizado para a rotina de Workflow   

Local cModHtm := ""
Local cPara   := ""
Local lRet		:= .F.
Local cID		:= ""
Local cPasta	:= "\messenger\emp" + cEmpAnt
Local cCdUsrF
Local cCdUsrP	:= aWFDados[8]
Local cCdCntg := aWFDados[3]
Local cIdALI	:= aWFDados[15]
local lWFDescont	:= ExistBlock("WFPCOA530") // Descontinuacao do workflow

 
If nTipoWF == 2 //FLUIG
		
	// Verifica se usuแrio existe no Fluig
	cCdUsrF := FWWFColleagueId( cCdUsrP )
	
	If !Empty( cCdUsrF )
		// Cria o processo de Workflow no Fluig
		If lWFDescont 
			lRet := ExecBlock("WFPCOA530", .F., .F., { cCdUsrP, cCdUsrF, cCdCntg, cIdALI })
		Else
			Help(" ",1,"PCOWFDESCONT",,STR0112,1,0)//""O processo de workflow encontra-se descontinuado para mais informa็?es acesse https://tdn.totvs.com/pages/viewpage.action?pageId=631621222 o mesmo foi transformado em um rdmake/pe.""
		EndIF
	Else
		MsgAlert( STR0090 + UsrRetName( cCdUsrP ) + STR0091 ) //"O usuแrio " + "######" + " nใo existe no Fluig"
	EndIf

ElseIf nTipoWF == 1 //E-MAIL

	cPara := AllTrim(aWFDados[1])
	
	If cPara == ""
	   Alert(STR0035) //"Usuแrio aprovador nใo possui conta de email cadastrada."
	   Return .F.
	Endif	
	
	//Chama a funcao para criacao do HTML
	cModHtm := Pc530HTMWF(aWFDados)
	
	If AllTrim(cModHtm) == ""
	   Alert(STR0060) //"Nใo foi possํvel gerar o arquivo de Email"
	   Return .F.
	EndIf
	
	lRet := !Empty(cPara)
	
	If lRet
		// Inicializa a classe TWFProcess (WorkFlow).
		oP := TWFProcess():New( "ALTBLQ", STR0097 ) //"ALERTA DE BLOQUEIO"
					
		// Cria uma nova tarefa para o processo.
		oP:NewTask("100010", cModHtm)
					
		//Assunto do E-Mail
		oP:cSubject := STR0036 + aWFDados[4] + STR0037 + cEmpAnt + STR0038 + aWFDados[2] //"Alerta de Bloqueio: "###" - Empresa "###" / Filial: "
					
		//Processo que sera executado para a resposta do E-Mail
		oP:bReturn  := "PCOA530RET()" 
					
		// Tempos limite de espera das respostas, em dias, horas e minutos.
		oP:bTimeout := {{"PCOA530OUT()",0,4,0}}
					
		// Define o destinatแrio do WorkFlow.
		oP:cTo := cPara  
					
		// Faz uso do objeto ohtml que pertence ao processo.
		oHtml := oP:oHtml
							
		// Assinala os valores no html.	
		oHtml:ValByName("EMPRESA",cEmpAnt)
		oHtml:ValByName("FILIAL", aWFDados[2])
		oHtml:ValByName("CDCNTG", aWFDados[3])
		oHtml:ValByName("CODBLQ", aWFDados[4])
	    
		DbSelectArea("ALI")
		DbGoto(aWFDados[14])
		RecLock("ALI", .F.)
		ALI->ALI_PROCWF := oP:fProcessID + oP:fTaskID  
		MSUnlock()
								
		// Gerando os arquivos de controle deste processo e enviando a mensagem.
		cID := oP:Start(cPasta)
	
		If File( cPasta + "\" + cID + ".htm")
	      PCO530CPY(cPasta + "\" + cID + ".htm",cModHtm)
		EndIf
	 	   
	Else
		If File(cModHtm)
			FErase(cModHtm)
		EndIf
					
		MsgAlert(STR0039) //"Nใo existe nenhum aprovador com E-Mail cadastrado."
	EndIf
			
	RestArea(aArea)
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPc530HTMWF บAutor  ณRafael Marin        บ Data ณ  19/09/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para gera็ใo do arquivo HTML utilizado no Workflow   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/                   
Function Pc530HTMWF(aWFDados)
Local aArea			:= GetArea()
Local cHTM			:= ""                                                                      
Local cMailBox		:= AllTrim(WFGetMV( "MV_WFMLBOX", NIL ))
Local cDe			:= ""
Local cPasta		:= "\messenger\emp"+ cEmpAnt
Local cArqHTM		:= CriaTrab( NIL , .F. ) + ".htm"
Local nHdl			:= Fcreate(cPasta+ "\" +cArqHTM)			//Numero do arquivo na memoria  
Local cUrl			:= "http://"
Local cAux			:= ""
Local lPco530Brw	:= ExistBlock("PCO530BRW")
Local lPco530Htm	:= ExistBlock("PCO530HTM")
Local cAuxHtm		:= ""
Local lPcoTls		:= SUPERGETMV("MV_PCOTLS",.F.,.F.)

cUrl += alltrim( GetMV( "MV_WFBRWSR" ) )  //obtendo o endere็o do servidor HTTP  (localhost/wf)
cUrl += STRTRAN(cPasta, "\", "/")

If lPco530Brw
	cAux := ExecBlock("PCO530BRW",.F.,.F.,{cUrl,cPasta})
	If ValType(cAux) != Nil .And. !Empty(cAux)
		cUrl := cAux	
	EndIf
EndIf

dbSelectArea("WF7")
WF7->(dbSetOrder(1))
If dbSeek(xFilial("WF7") + cMailBox)
	cDe := Trim(WF7->WF7_ENDERE)
Else
   Help(" ", 1, "PCO530GerH", , STR0101, 1, 0) //"Conta de WorkFlow nใo cadastrada corretamente."   
   Return ""
Endif	

cHTM := '<html xmlns="http://www.w3.org/1999/xhtml">'+ CRLF +;
		'<head>'+ CRLF+;
		'<title>'+STR0041+' - Protheus 10</title>'+ CRLF+;
		'<style type="text/css">'+ CRLF+;
		'<!--'+ CRLF+;
		'body {'+ CRLF+;
		'	background-image:url(../imagens/body-fundo.gif);	'+ CRLF+;
		'	margin-top: 0px;'+ CRLF+;
		'	margin-left: 0px;'+ CRLF+;
		'	margin-right: 0px;'+ CRLF+;
		'	margin-bottom: 0px;'+ CRLF+;
		'	padding-top: 0px;'+ CRLF+;
		'	padding-left: 0px;'+ CRLF+;
		'}'+ CRLF+;
		'.body-topo {'+ CRLF+;
		'	background:url(../imagens/topo_fundo.jpg) repeat-x;'+ CRLF+;
		'	background-color:#333333;'+ CRLF+;
		'	margin-top: 0px;'+ CRLF+;
		'	margin-left: 0px;'+ CRLF+;
		'	margin-right: 0px;'+ CRLF+;
		'	margin-bottom: 0px;'+ CRLF+;
		'	padding-top: 0px;'+ CRLF+;
		'	padding-left: 0px;'+ CRLF+;
		'}'+ CRLF+;
		'.tabconteudo1 {'+ CRLF+;
		'	background: url(../imagens/conteudo_fundo_1.gif ) top left no-repeat; '+ CRLF+;
		'	background-color:#fff;'+ CRLF+;
		'	margin-top: 0px;'+ CRLF+;
		'	margin-left: 0px;'+ CRLF+;
		'	margin-right: 0px;'+ CRLF+;
		'	margin-bottom: 0px;'+ CRLF+;
		'	padding-top: 0px;'+ CRLF+;
		'	padding-left: 0px;'+ CRLF+;
		'}'+ CRLF+;
		'.tabconteudo2 {'+ CRLF+;
		'	background: url(../imagens/conteudo_fundo_2.gif ) top repeat-x; '+ CRLF+;
		'	background-color:#fff;'+ CRLF+;
		'	margin-top: 0px;'+ CRLF+;
		'	margin-left: 0px;'+ CRLF+;
		'	margin-right: 0px;'+ CRLF+;
		'	margin-bottom: 0px;'+ CRLF+;
		'	padding-top: 0px;'+ CRLF+;
		'	padding-left: 0px;'+ CRLF+;
		'}'+ CRLF+;
		'.tabconteudo3 {'+ CRLF+;
		'	background: url(../imagens/conteudo_fundo_3.gif ) top right no-repeat; '+ CRLF+;
		'	background-color:#fff;'+ CRLF+;
		'	margin-top: 0px;'+ CRLF+;
		'	margin-left: 0px;'+ CRLF+;
		'	margin-right: 0px;'+ CRLF+;
		'	margin-bottom: 0px;'+ CRLF+;
		'	padding-top: 0px;'+ CRLF+;
		'	padding-left: 0px;'+ CRLF+;
		'}'+ CRLF+;
		'.tab_fundo{'+ CRLF+;
		'	background:url(../imagens/tab_fundo.jpg) repeat-x;'+ CRLF+;
		'A:hover {TEXT-DECORATION: underline !important;}'+ CRLF+;
		'A:link {TEXT-DECORATION: none;}'+ CRLF+;
		'A:active {}'+ CRLF+;
		'A:visited {TEXT-DECORATION: none;}'+ CRLF+;
		'}'+ CRLF+;
		'.texto {'+ CRLF+;
		'	FONT-SIZE: 11px; '+ CRLF+;
		'	COLOR: #454545; '+ CRLF+;
		'	FONT-FAMILY: Verdana, Arial, Helvetica, sans-serif;'+ CRLF+;
		'	line-height:18px;'+ CRLF+;
		'}'+ CRLF+;
		'.textoBold {'+ CRLF+;
		'	FONT-SIZE: 11px;'+ CRLF+;
		'	COLOR: #454545;'+ CRLF+;
		'	FONT-FAMILY: Verdana, Arial, Helvetica, sans-serif;'+ CRLF+;
		'	font-weight: bold;'+ CRLF+;
		'}'+ CRLF+;
		'.textoPeq {'+ CRLF+;
		'	FONT-SIZE: 9px; '+ CRLF+;
		'	COLOR: #757575; '+ CRLF+;
		'	FONT-FAMILY: Verdana, Arial, Helvetica, sans-serif;'+ CRLF+;
		'}'+ CRLF+;
		'.textoPeqBold {'+ CRLF+;
		'	FONT-SIZE: 9px;'+ CRLF+;
		'	COLOR: #757575;'+ CRLF+;
		'	FONT-FAMILY: Verdana, Arial, Helvetica, sans-serif;'+ CRLF+;
		'	font-weight: bold;'+ CRLF+;
		'	line-height:15px;'+ CRLF+;
		'}'+ CRLF+;
		'.combo {'+ CRLF+;
		'	FONT-SIZE: 9px; '+ CRLF+;
		'	COLOR: #FFFFFF; '+ CRLF+;
		'	FONT-FAMILY: Verdana, Arial, Helvetica, sans-serif;'+ CRLF+;
		'	border-style:none;'+ CRLF+;
		'	background: url(../imagens/input_fundo.gif);'+ CRLF+;
		'	width:160px;'+ CRLF+;
		'	height:20px;'+ CRLF+;
		'	padding-left:6px;'+ CRLF+;
		'	padding-top:5px;'+ CRLF+;
		'	line-height:20px;'+ CRLF+;
		'}'+ CRLF+;
		'.comboselect {'+ CRLF
cHTM += '	FONT-SIZE: 9px; '+ CRLF+;
		'	COLOR: #FFFFFF; '+ CRLF+;
		'	FONT-FAMILY: Verdana, Arial, Helvetica, sans-serif;'+ CRLF+;
		'	background-color:#36373B;'+ CRLF+;
		'	width:160px;'+ CRLF+;
		'	height:18px;'+ CRLF+;
		'	padding-top:2px;'+ CRLF+;
		'}'+ CRLF+;
		'.combo1 {'+ CRLF+;
		'	FONT-SIZE: 9px;'+ CRLF+;
		'	color:#666666;'+ CRLF+;
		'	FONT-FAMILY: Verdana, Arial, Helvetica, sans-serif;'+ CRLF+;
		'	border:solid 1px #999999;'+ CRLF+;
		'}'+ CRLF+;
		'.linksPeq, .links {'+ CRLF+;
		'	FONT-WEIGHT: bold;'+ CRLF+;
		'	FONT-SIZE: 9px;'+ CRLF+;
		'	COLOR: #FFFFFF;'+ CRLF+;
		'	FONT-FAMILY: Verdana, Arial, Helvetica, sans-serif;'+ CRLF+;
		'	TEXT-DECORATION: underline !important;'+ CRLF+;
		'	line-height: 15px;'+ CRLF+;
		'}'+ CRLF+;
		'.links {'+ CRLF+;
		'	FONT-SIZE: 9px;'+ CRLF+;
		'	A:hover {COLOR: #FFFFFF; TEXT-DECORATION: underline !important;}'+ CRLF+;
		'	A:link {COLOR: #FFFFFF; TEXT-DECORATION: none;}'+ CRLF+;
		'	A:active {COLOR: #FFFFFF;}'+ CRLF+;
		'	A:visited {COLOR: #FFFFFF; TEXT-DECORATION: none;}'+ CRLF+;
		'}'+ CRLF+;
		'.links_login {'+ CRLF+;
		'	FONT-SIZE: 9px;'+ CRLF+;
		'	COLOR: #7C87A4;'+ CRLF+;
		'	FONT-FAMILY: Verdana, Arial, Helvetica, sans-serif;'+ CRLF+;
		'	TEXT-DECORATION: underline !important;'+ CRLF+;
		'}'+ CRLF+;
		'.titulo {'+ CRLF+;
		'	FONT-WEIGHT: bold; '+ CRLF+;
		'	FONT-SIZE: 20px; '+ CRLF+;
		'	COLOR: #49577E; '+ CRLF+;
		'	FONT-FAMILY: Arial, Helvetica, sans-serif; '+ CRLF+;
		'	TEXT-DECORATION: none'+ CRLF+;
		'}'+ CRLF+;
		'.sub-titulo {'+ CRLF+;
		'	FONT-WEIGHT: bold; '+ CRLF+;
		'	FONT-SIZE: 11px; '+ CRLF+;
		'	COLOR: ; '+ CRLF+;
		'	FONT-FAMILY: Verdana, Arial, Helvetica, sans-serif; '+ CRLF+;
		'	TEXT-DECORATION: none'+ CRLF+;
		'}'+ CRLF+;
		'.botao {'+ CRLF+;
		'	FONT-SIZE: 9px;'+ CRLF+;
		'	COLOR: #666666;'+ CRLF+;
		'	FONT-FAMILY: Verdana, Arial, Helvetica, sans-serif;'+ CRLF+;
		'	border: 1px solid #333333;'+ CRLF+;
		'	font-weight: bold;'+ CRLF+;
		'	margin: 1px;'+ CRLF+;
		'	padding: 1px;'+ CRLF+;
		'	cursor:hand;'+ CRLF+;
		'}'+ CRLF+;
		'.tabform {'+ CRLF+;
		'	font-family:Verdana, Arial, Helvetica, sans-serif;'+ CRLF+;
		'	font-size:9px;'+ CRLF+;
		'	font-weight:bold;'+ CRLF+;
		'	text-indent:4px;'+ CRLF+;
		'	color:#333333;'+ CRLF+;
		'	line-height:20px;'+ CRLF+;
		'	border-top: #ffffff solid 1px;'+ CRLF+;
		'	border-bottom: #F1F1F1 solid 1px;'+ CRLF+;
		'	border-right: #EFEFEF solid 1px;'+ CRLF+;
		'	background-color:#FFFFFF;'+ CRLF+;
		'}'+ CRLF+;
		'.tabformm {'+ CRLF+;
		'	font-family:Verdana, Arial, Helvetica, sans-serif;'+ CRLF+;
		'	font-size:9px;'+ CRLF+;
		'	font-weight:bold;'+ CRLF+;
		'	text-indent:4px;'+ CRLF+;
		'	color:#333333;'+ CRLF+;
		'	line-height:20px;'+ CRLF+;
		'	border-top: #ffffff solid 1px;'+ CRLF+;
		'	border-bottom: #F1F1F1 solid 1px;'+ CRLF+;
		'	background-color:#FFFFFF;'+ CRLF+;
		'}'+ CRLF+;
		'.tabform1 {'+ CRLF+;
		'	font-family:Verdana, Arial, Helvetica, sans-serif;'+ CRLF+;
		'	font-size:9px;'+ CRLF+;
		'	color:#333333;'+ CRLF+;
		'	text-indent:4px;'+ CRLF+;
		'	line-height:20px;'+ CRLF+;
		'	border-top: #ffffff solid 1px;'+ CRLF+;
		'	border-bottom: #F1F1F1 solid 1px;'+ CRLF+;
		'	background-color: #F7F7F7;'+ CRLF+;
		'}'+ CRLF+;
		'.tabform11 {'+ CRLF+;
		'	font-family:Verdana, Arial, Helvetica, sans-serif;'+ CRLF+;
		'	font-size:9px;'+ CRLF+;
		'	color:#333333;'+ CRLF+;
		'	text-indent:4px;'+ CRLF+;
		'	line-height:20px;'+ CRLF+;
		'	border-top: #ffffff solid 1px;'+ CRLF
cHTM += '	border-bottom: #F1F1F1 solid 1px;'+ CRLF+;
		'	border-right: #EFEFEF solid 1px;'+ CRLF+;
		'	background-color: #F7F7F7;'+ CRLF+;
		'}'+ CRLF+;
		'.tab_borderazul{'+ CRLF+;
		'	border-bottom:#E5E5E5 solid 1px;'+ CRLF+;
		'	border-top:#E5E5E5 solid 1px;'+ CRLF+;
		'	border-left:#E5E5E5 solid 1px;'+ CRLF+;
		'	border-right:#E5E5E5 solid 1px;'+ CRLF+;
		'}'+ CRLF+;
		'-->'+ CRLF+;
		'</style>'+ CRLF+;
		'</head>'+ CRLF+;
		'<body class="body-topo">' + CRLF+;
		'<table width="100%" border="0" cellspacing="0" cellpadding="0">' + CRLF+;
		'  <tr>' + CRLF+;
		'  		<td width="74%" align="center">&nbsp;</td>' + CRLF+;
		'  	</tr>' + CRLF+;
		'  <tr>' + CRLF+;
		'  	<td colspan="3" align="center"><table width="98%" border="0" align="center" cellpadding="0" cellspacing="0">' + CRLF+;
		'		<tr>' + CRLF+;
		'			<td width="2%" class="tabconteudo1">&nbsp;</td>' + CRLF+;
		'			<td width="96%" class="tabconteudo2" align="center"><table width="100%" border="0" align="center" cellpadding="0" cellspacing="4">' + CRLF+;
		'				<tr>' + CRLF+;
		'					<td>&nbsp;</td>' + CRLF+;
		'				</tr>' + CRLF+;
		'				<tr>' + CRLF+;
		'					<td><span class="titulo">'+STR0041+'</span></td>' + CRLF+;
		'				</tr>' + CRLF+;
		'				<tr>' + CRLF+;
		'					<td class="texto">&nbsp;</td>' + CRLF+;
		'				</tr>' + CRLF+;
		'				<tr>' + CRLF+;
		'					<td class="texto"><table width="100%" border="0" cellspacing="0" cellpadding="0">' + CRLF+;
		'							<tr>' + CRLF+;
		'								<td height="1" colspan="7" bgcolor="#F1F1F1"></td>' + CRLF+;
		'							</tr>' + CRLF+;
		'							<tr>' + CRLF+;
		'								<td width="14%" class="tabform">'+ STR0042 +'</td>' + CRLF+;//'Solicitante'
		'								<td width="16%" align="center" class="tabform">'+STR0043+'</td>' + CRLF+; //Dt.Solicitacao
		'								<td width="16%" align="center" class="tabform">'+STR0044+'</td>' + CRLF+; //Dt.Validade
		'								<td width="14%" class="tabform">'+STR0045+'</td>' + CRLF+; //'Cod.Cont.'
		'								<td width="11%" class="tabform">'+STR0046+'</td>' + CRLF+; //'Cod. Bloq.'
		'								<td width="12%" class="tabform">'+STR0047+'</td>' + CRLF+; //'Processo'
		'								<td width="17%" class="tabformm">'+STR0048+'</td>' + CRLF+; //'Lote ID'
		'							</tr>' + CRLF+;
		'							<tr>' + CRLF+;                             
		'								<td class="tabform11">'+aWFDados[13]+'</td>' + CRLF+;
		'								<td align="center" class="tabform11">'+DTOC(aWFDados[10])+'</td>' + CRLF+;
		'								<td align="center" class="tabform11">'+DTOC(aWFDados[9])+'</td>' + CRLF+;
		'								<td class="tabform11">'+aWFDados[3]+ '</td>' + CRLF+;
		'								<td class="tabform11">'+aWFDados[4]+ '</td>' + CRLF+;
		'								<td class="tabform11">'+aWFDados[5]+ '</td>' + CRLF+;
		'								<td class="tabform1">'+aWFDados[6]+  '</td>' + CRLF+;
		'							</tr>' + CRLF+;
		'					</table></td>' + CRLF+;
		'				</tr>' + CRLF+;
		'				<tr>' + CRLF+;
		'					<td class="textoPeq">&nbsp;</td>' + CRLF+;
		'				</tr>' + CRLF+;
		'				<tr>' + CRLF+;
		'					<td class="textoPeq"><table width="100%" border="1" cellpadding="8" cellspacing="0" bordercolor="#E5E5E5" class="tab_fundo">' + CRLF+;
		'							<tr>' + CRLF+;
		'								<td class="textoPeq" bordercolor="#FFFFFF"><span class="textoPeqBold">'+STRTRAN(aWFDados[7], CHR(13)+CHR(10), "<br>")+'</span><br>' + CRLF+;
		'							</tr>' + CRLF+;
		'					</table></td>' + CRLF+;
		'				</tr>' + CRLF+;
		'				<tr>' + CRLF+;
		'					<td class="textoPeq">&nbsp;</td>' + CRLF+;
		'				</tr>' + CRLF+;
		'				<tr>' + CRLF
If lPcoTls
	cHTM += '				<FORM name=form1 action="mailto:'+cDe+'" method=post> ' + CRLF //Tratamento no envio de e-mail para o protocolo TLS.
Else
	cHTM += '				<FORM name=form1 action=WFHTTPRET.APL    method=post> ' + CRLF
EndIf
cHTM += '					<td class="textoPeq"><table width="100%" border="1" cellpadding="8" cellspacing="0" bordercolor="#E5E5E5" class="tab_fundo">' + CRLF+;
		'							<tr>' + CRLF+;
		'								<td align="center" bordercolor="#FFFFFF" class="textoPeq"><table width="33%" border="0" align="center" cellpadding="0" cellspacing="0">' + CRLF+;
		'										<tr>' + CRLF+;
		'											<td width="49%"><input name="%APROVA%" type="radio" value="Sim">' + CRLF+;
		'													<span class="texto">'+STR0049+'</span></td>' + CRLF+; //"Aprova"
		'											<td width="51%"><input name="%APROVA%" type="radio" value="Nใo">' + CRLF+;
		'													<span class="texto">'+STR0050+'</span></td>' + CRLF+;
		'													<input type="hidden" name="%EMPRESA%" value="'+cEmpAnt+'">'+ CRLF+;
		'													<input type="hidden" name="%FILIAL%" value="'+aWFDados[2]+'">'+ CRLF+;
		'													<input type="hidden" name="%CDCNTG%" value="'+aWFDados[3]+'">' + CRLF+;
		'													<input type="hidden" name="%CODBLQ%" value="'+aWFDados[4]+'">' + CRLF+;
		'													<input type="hidden" name="%ID%" value="'+cPasta+ "\" +cArqHTM+'">' + CRLF+;
		'													<input type="hidden" name="%USUARIO%" value="'+aWFDados[8]+'">' + CRLF+;
		'										</tr>' + CRLF+;
		'										<tr>' + CRLF+;
		'											<td colspan="2">&nbsp;</td>' + CRLF+;
		'										</tr>' + CRLF+;
		'										<tr>' + CRLF+;
		'											<td colspan="2" align="center"><span class="texto">' + CRLF+;
		'												<input name="Submit3" type="submit" class="botao" value="'+STR0051+'">' + CRLF+;
		'											</span></td>' + CRLF+;
		'										</tr>' + CRLF+;
		'								</table></td>' + CRLF+;
		'							</tr>' + CRLF+;
		'						</table>' + CRLF+;
		'							<br>' + CRLF+;
		'							<span class="texto"><br>' + CRLF+;
		'						</span></td>' + CRLF
cHTM += '				</FORM>	
cHTM += '				</tr>' + CRLF

cHTM += '			</table></td>' + CRLF+;
		'			<td width="2%" class="tabconteudo3">&nbsp;</td>' + CRLF+;
		'		</tr>' + CRLF+;
		'	</table></td>' + CRLF+;
		'  	</tr>' + CRLF+;
		'  	<tr>' + CRLF+;
		'  	<td colspan="3" align="center"><a class="links" href="'+cUrl+"\"+cArqHTM+'">'+STR0059+'</a></td>' + CRLF+; //'">Caso tenha algum problema em responder este formulแrio clique aqui.</a></td>'
		'  	</tr>' + CRLF+;
		'</table>' + CRLF+;
		'</body>' + CRLF+;
		'</html>' + CRLF

If lPco530Htm
	cAuxHtm := ExecBlock("PCO530HTM",.F.,.F.,{cHTM})
	If ValType(cAuxHtm) != Nil .And. !Empty(cAuxHtm)
		cHTM := cAuxHtm	
	EndIf
EndIf

FWrite(nHdl,cHTM,Len(cHTM))	

//Fecha LOG
FClose(nHdl)                            

cHTM := ""
Ms_Flush()
RestArea(aArea)

Return (cPasta+ "\" +cArqHTM)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOA530OUTบAutor  ณRafael Marin        บ Data ณ  19/09/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina de controle de TimeOut do WorkFlow                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PCOA530OUT(oP)

// Faz um reenvio da mensagem... 
oP:cSubject += STR0052 + oP:ProcessID() + STR0053  //"(Timeout processo: "###") REENVIO: 1"
CONOUT(oP:cSubject) 
// Envia novamente a mensagem.
oP:Start()

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOA530RETบAutor  ณRafael Marin        บ Data ณ  19/09/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina de processamento de Resposta do WorkFlow             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function PCOA530RET(__oProc) 
Local oHtml		:= __oProc:oHtml
Local cFile		:= AllTrim(oHtml:RetByName("ID"))
Local cFilMail	:= AllTrim(oHtml:RetByName("FILIAL"	))
Local cCDCNTG	:= AllTrim(oHtml:RetByName("CDCNTG"	))
Local cCODBLQ	:= AllTrim(oHtml:RetByName("CODBLQ"	))
Local cUsuario  := AllTrim(oHtml:RetByName("USUARIO"))
Local cLibera   := AllTrim(oHtml:RetByName("APROVA"))          // Obtem a resposta do Aprovador.
Local lLibera   := IIF(cLibera == 'Sim',.T.,.F.)

ALI->(DbSetorder(1))
IF ALI->(DbSeek(PadR(cFilMail, Len(xFilial("ALI")))+cCDCNTG+cUsuario))
                      
		If ALI->ALI_STATUS $ "03/05"
			Help(" ", 1, "PCO530Ret", , STR0098, 1, 0) //"Solicita็ใo de contingencia ja liberada!"
		ElseIf ALI->ALI_STATUS == "01"
			Help(" ", 1, "PCO530Ret", , STR0099, 1, 0) //"Solicita็ใo de contingencia aguardando liberacao de nivel anterior!"
		ElseIf ALI->ALI_STATUS $ "04/06"
			Help(" ", 1, "PCO530Ret", , STR0100, 1, 0) //"Solicita็ใo de contingencia ja cancelada!"
		Else
			If lLibera
				PCOA500GER(.T., cCODBLQ, cUsuario)
			Else
				PCOA530ALC(6, cCodBlq,,.T., cUsuario) //Rejeitando libera็ใo se resposta negativa	
			EndIf		                                                               				
		EndIF
Else
	Help(" ", 1, "PCO530Ret", , STR0056 + cCDCNTG + STR0057, 1, 0) //"RETORNO - Contingencia "###" nใo encontrada"
Endif

//Apaga o arquivo HTML gerado
If File(cFile)
	FErase(cFile)
EndIf

// Finaliza o processo.
__oProc:Finish()

Return Nil    


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA530SelCTsบAutor  ณ Acaico Egas        บ Data ณ  09/22/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina de empenho de contingencias aprovadas.              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function A530SelCTs( cTxtBlq )

Local l53005	:= ExistBlock( "PCOA5305" ) // Ponto de entrada para manipula็ใo dos dados da contingencia
Local nValCtg
Local nValEmp

Local oDlg,oBrwALJ,oGrpCt
Local nGetD,Nx,nI
Local lRet := .F.
Local cSayHTML
Local nTot := 0
Local aCpos,aHeadBrw		:= {}
Local aButtons		:= {}
Local oFntAR14	:= TFont():New("Arial",0,12,,.F.,,,,.F.,.F.)
Local aAreaAKD
Local _aCtgs 
Local lP530CTG := ExistBlock("P530CTG")
Local nLinIni := 0 
Local nColIni := 0
Local nLinEnd := 0
Local nColEnd := 0
Local oSize

Private oOk	:= LoadBitmap(GetResources(), 'lbok')
Private oNo := LoadBitmap(GetResources(), 'lbno')

//************************************
// aCtgs = Vetor com Contignecias    *
//  [x,1]= Check box                 *
//  [x,2]= Codigo da Contingencia    *
//  [x,3]= Nome do Usuario           *
//  [x,4]= Data da Solicitacao       *
//  [x,5]= Data da Liberacao         *
//  [x,6]= Valor da Contingencia     *
//  [x,7]= Valor Empenhado           *
//  [x,8]= Total                     *
//  [x,9]= Vetor com Tabela ALI      *
//  [x,10]= Deleta do Liste			 *
//************************************

aCpos := {'',"ALJ_CDCNTG","ALI_NOMSOL","ALI_DTSOLI","ALI_DTLIB","ALJ_VALOR1","ALJ_EMPVAL"}

#DEFINE N_CTGCHK	1 // Check box da contignecia
#DEFINE N_CODCTG	2 // Codigo da Contingencia
#DEFINE N_NOMSOL	3 // Nome do Solicitante
#DEFINE N_DTSOLI 	4 // Data da Solicita็ใo
#DEFINE N_DTLIBE	5 // Data da libera็ใo
#DEFINE N_VLRCTG	6 // Valor da Contingencia
#DEFINE N_VLREMP	7 // Valor empenhado pela contingencia
#DEFINE N_TOTCTG	8 // Total utilizado pela contingencia ( N_VLRCTG + N_VLREMP)
#DEFINE N_VETALI	9 // Vetor com linhas da ALI (aprovadores para a contigencia)
#DEFINE N_DELETE	10// controle de contignecias ja uttilizadas

_aCtgs := CntgFind()

If lP530CTG
	_aCtgs := ExecBLock("P530CTG",.F.,.F.,{_aCtgs})	
EndIf

SX3->(DbSetOrder(2))

For Nx := 1 To Len(aCpos)

	If SX3->(DbSeek(aCpos[Nx])) .and. !Empty(aCpos[Nx])

		aAdd( aHeadBrw , Trim(X3Titulo()) )

	Else

		aAdd( aHeadBrw , '' )
	
	EndIf
Next


If Len(_aCtgs)==0

	aAdd( _aCtgs , { .F. , '' , '' , '' , '' , 0 , 0 , 0 , {} } )

EndIf

nValCtg	:= _aDadosBlq[2]-_aDadosBlq[3]

//*********************************************************
//      Blindagem para que o Empenho nใo sejแ negativo    *
//--------------------------------------------------------*
// Isso pode acorrer caso a conta que estแ sendo alterado *
// jแ esteja virada (Saldo negativo).                     *
//*********************************************************

If (AKD->AKD_VALOR1 - _nVldEmpAKD) > nValCtg

	nValEmp	:= (AKD->AKD_VALOR1 - _nVldEmpAKD) - nValCtg

Else

	nValEmp	:= 0

EndIf



If l53005
	//P_Eฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//P_Eณ Ponto de entrada utilizado manipular o valor da contingencia e o       ณ
	//P_Eณ valor do empenho.                                                      ณ
	//P_Eณ Parametros :                                                           ณ
	//P_Eณ     Pramixb[1] = Valor da contingencia                                 |
	//P_Eณ     Pramixb[2] = Valor do Empenho da contingencia                      |
	//P_Eณ     Pramixb[3] = Valor total do item                                   |
	//P_Eณ Retorno    : Array com os seguintes elementos                          ณ
	//P_Eณ     Elemento 1: Valor da Contingencia.                                 ณ
	//P_Eณ     Elemento 2: Valor do Empenho da contingencia                       ณ
	//P_Eณ  Ex. :  User Function PCOA5305                                         ณ
	//P_Eณ              nValCtg := Paramixb[1]                                    ณ
	//P_Eณ              nValEmp := Paramixb[2]                                    ณ
	//P_Eณ              nTotItem := Paramixb[3]                                   ณ
	//P_Eณ         Return { nValCtg , nValEmp }                                   ณ
	//P_Eภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	aRet	:=	ExecBlock("PCOA5305",.F.,.F.,{nValCtg , nValEmp , AKD->AKD_VALOR1 })
	
	nValCtg	:= aRet[1]
	nValEmp	:= aRet[2]

EndIf

aadd(aButtons , {'CSAIMG32',{|| GrvContPCO(AKD->(Recno()), cTxtBlq,{ nValCtg,nValEmp },oBrwALJ) },"Solicitar" })

/* Inclusใo da op็ใo de Buscar contingencia por senha 
   Sequencia a realizar:

   1. Chamada da tela para informar a senha (DlgSenha), passando por referencia o array das conting๊ncias
   2. Refazendo a grid que exibira as conting๊ncias
   3. Realizando um refresh para atualizar o grid apenas com a conting๊ncia da senha informada
*/

aadd(aButtons , {'CSAIMG32',{|| DlgSenha(@_aCtgs,oBrwALJ), oBrwALJ:SetArray(_aCtgs);
		,oBrwALJ:bLine 		:= {|| { 	If(_aCtgs[oBrwALJ:nAt,N_CTGCHK],oOk,oNo) 	,;
										_aCtgs[oBrwALJ:nAt,N_CODCTG]				,;
										_aCtgs[oBrwALJ:nAt,N_NOMSOL]				,;
										_aCtgs[oBrwALJ:nAt,N_DTSOLI]				,;
										_aCtgs[oBrwALJ:nAt,N_DTLIBE]				,;
										_aCtgs[oBrwALJ:nAt,N_VLRCTG]				,;
										_aCtgs[oBrwALJ:nAt,N_VLREMP]				} };
		,oBrwALJ:Refresh() },STR0102 })

	DEFINE MSDIALOG oDlg TITLE STR0073 FROM 0,0 TO 400,800 PIXEL //"Utiliza็ใo de Contingencia Orcamentaria"
		oSize := FwDefSize():New(.T.,,,oDlg)
		oSize:AddObject( "CABECALHO",  100, 30, .T., .T. ) // Totalmente dimensionavel
		oSize:AddObject( "GETDADOS" ,  100, 70, .T., .T. ) // Totalmente dimensionavel 
		oSize:lProp 	:= .T. // Proporcional            
		oSize:Process() 	   // Dispara os calculos 
		
		nLinIni := oSize:GetDimension("CABECALHO","LININI") 
		nColIni := oSize:GetDimension("CABECALHO","COLINI") 
		nLinEnd := oSize:GetDimension("CABECALHO","LINEND") 
		nColEnd := oSize:GetDimension("CABECALHO","COLEND") 
 	  	
		oPnlCt 		:= TPanel():New( nLinIni+5 , nColIni+5, , oDlg, , , , , , nLinEnd-5 , nColEnd-5 , ,.t.)
		oPnlCt:Align 	:= CONTROL_ALIGN_ALLCLIENT

		oGrpCt	:= TGroup():New(10,10,nLinEnd,nColEnd-10,OemToAnsi(""),oPnlCt , , ,.t.)
		
		cSayHTML :=	GetlblTit(.F.)

		@ 15, 15 SAY oLblTit VAR cSayHTML OF oGrpCt FONT oFntAR14 SIZE 200 , 100 PIXEL HTML
		
		nLinIni := oSize:GetDimension("GETDADOS","LININI") 
		nColIni := oSize:GetDimension("GETDADOS","COLINI") 
		nLinEnd := oSize:GetDimension("GETDADOS","LINEND") 
		nColEnd := oSize:GetDimension("GETDADOS","COLEND") 
				
		oBrwALJ	:= TWBrowse():New( nLinIni, nColIni,nColEnd,nLinEnd-120, ,aHeadBrw,,oPnlCt,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
		oBrwALJ:SetArray(_aCtgs)
		oBrwALJ:bLine 		:= {|| { 	If(_aCtgs[oBrwALJ:nAt,N_CTGCHK],oOk,oNo) 	,;
										_aCtgs[oBrwALJ:nAt,N_CODCTG]				,;
										_aCtgs[oBrwALJ:nAt,N_NOMSOL]				,;
										_aCtgs[oBrwALJ:nAt,N_DTSOLI]				,;
										_aCtgs[oBrwALJ:nAt,N_DTLIBE]				,;
										_aCtgs[oBrwALJ:nAt,N_VLRCTG]				,;
										_aCtgs[oBrwALJ:nAt,N_VLREMP]				} }

		oBrwALJ:bLDblClick 	:= {|| Alltrim(oBrwALJ:aArray[oBrwALJ:nAt][2]) <> ""  .And. CtgDbClick(oBrwALJ , _aCtgs ,oLblTit , @nTot) }

	ACTIVATE MSDIALOG oDlg CENTERED ON INIT (oBrwALJ:Refresh(),EnchoiceBar(oDlg,{|| If( ((_aDadosBlq[2]-_aDadosBlq[3]) <= nTot) , (lRet := .T. , oDlg:End()) , .F. ) },{|| oDlg:End() },,aButtons) )

If lRet
	// Efetua lan็amento de Estorno do empenho de saldo para contingencia

	For nX := 1 To Len(_aCtgs)
	
		If _aCtgs[nX,N_CTGCHK]
		
			DbSelectArea("ALJ")
			DbSetOrder(1)
			If DbSeek( xFilial("ALJ") + _aCtgs[nX,N_CODCTG] )

				aAreaAKD := AKD->(GetArea())
				
				cChave := Padr("ALJ"+&(IndexKey())+ "02",Len(AKD->AKD_CHAVE))
				DbSelectArea("AKD")
				DbSetOrder(10)
				If DbSeek(xFilial("AKD") + cChave )

					// Utilizado para recuperar lan็amentos caso processo seja cancelado
					PcoBackupAKD(aCntgBak)
					PcoIniLan("000356",.F.)
					PcoDetLan("000356","02","PCOA530",.T.)
					PcoFinLan("000356",,,.F.)				
									
				EndIf

				// O PcoIniLan deve ser repetido para nao dar erro de UNQ no Recall do Empenho
				PcoIniLan("000356",.F.)
				PcoDetLan("000356","01","PCOA530")
				DbSelectArea("ALJ")// Utilizado para apagar lan็amento caso processo seja cancelado
				cChave := Padr("ALJ"+&(IndexKey())+ "01",Len(AKD->AKD_CHAVE))
				DbSelectArea("AKD")
				DbSetOrder(10)
				If DbSeek(xFilial("AKD") + cChave )
					aAdd(aCntgBak, { AKD->(Recno()), {} } )
				EndIf
				PcoFinLan("000356",,,.F.)
				
				_lLibCtg     := .T.

				RestArea(aAreaAKD)

			EndIf

		EndIf

	Next

EndIf

Return lRet

//ษออออออออออออออออออออออออออออออออออออออออออออออออออออป
//บ Duplo click na Browse de continencias              บ
//ศออออออออออออออออออออออออออออออออออออออออออออออออออออผ
Static Function CtgDbClick( oBrw , _aCtgs ,oLbl , nTot)

Local nAt 		:= oBrw:nAt
Local cSayHtml 	:= ""
Local aRet
Local lContinua := .T.
Local lSenha	:= SUPERGETMV("MV_PCOCTGP",.F.,.F.)

nTot 			:= 0
If !Empty(_aCtgs[nAt,N_DTLIBE])

	DbSelectArea("ALJ")
	DbSetOrder(1)
	DbSeek(xFilial("ALJ") + _aCtgs[nAt,N_CODCTG] )

	If !Empty(_aDadosBLQ) .And. !Empty(_aDadosBLQ[5])
		If ALJ->ALJ_PROCES <> _aDadosBLQ[5]
			ApMsgInfo(STR0109, STR0110) //"O processo selecionado percente a uma rotina diferente da utilizada" //"Aten็ใo"
			lContinua := .F.
		EndIf
	EndIf
	
	If !Empty(_aDadosBLQ) .And. !Empty(_aDadosBLQ[11])
		cChvctg:= STRTRAN(_aDadosBLQ[11],"AKD","ALJ")

		If &(cChvctg) <> _aDadosBLQ[4]
			ApMsgInfo(STR0113+"["+ alltrim(_aDadosBlq[8])+"]",STR0110) //"Chave nใo confere: "
			lContinua := .F.
		EndIf
	EndIf


	If lSenha .and. !_aCtgs[nAt,N_CTGCHK] .And. lContinua// Se utiliza senha e o check nใo esta ativo

		// Apresenta o Dialog para digita็ใo da senha.
				If Senhabox({{1, STR0075 , SPACE(6), "@N!", "", "", "", 30, .T.}}, STR0074 , @aRet)  //"Senha"###"Senha de contingencia."

			// valida a senha digitada para prosseguir
			lContinua := PcoCtngKey(aRet[1],ALJ->(Recno()),.F.)
			If !lContinua
				Aviso(STR0076,STR0077,{STR0078}) //"Aten็ใo!"###"A senha digitada ้ Invalida!"###"OK"
			EndIf

		Else

			lContinua := .F. // senha invalida

		EndIf

	EndIf
	
	If lContinua

		_aCtgs[nAt,N_CTGCHK] 	:= !_aCtgs[nAt,N_CTGCHK]
		aEval( _aCtgs , {|x| If( x[N_CTGCHK] , nTot+=x[N_TOTCTG], .F.) } )
		
		cSayHtml := GetlblTit( ((_aDadosBlq[2]-_aDadosBlq[3]) <= nTot) )
		oLbl:CCAPTION	:= cSayHtml
		oLbl:Refresh()

	EndIf

Else

	Aviso(STR0076,STR0079,{STR0078})//"Aten็ใo!"###"Estแ solicita็ใo estแ aguardando libera็ใo!"###"OK"

EndIf

Return

//ษออออออออออออออออออออออออออออออออออออออออออออออออออออป
//บ Monta mensagem  da tela de sele็ใo de contingencia บ
//ศออออออออออออออออออออออออออออออออออออออออออออออออออออผ
Static Function GetlblTit(lOk)

Local cCodCubo,cCube,cChaveAtu,cSayHTML
Local nPos
Local nTpVersao := GetRemoteType()

cCodCubo := Posicione("AL4", 1, xFilial("AL4")+AKJ->AKJ_REACFG, "AL4_CONFIG")	              

dbSelectArea("AKW")
dbSetOrder(1)
MsSeek(xFilial("AKW")+cCodCubo)         
             
cCube	:= ""
nPos	:=	1
While (!Eof()) .And. (AKW->AKW_FILIAL+AKW->AKW_COD == xFilial("AKW")+cCodCubo) .And. (AKW->AKW_NIVEL <= AKJ->AKJ_NIVPR)
	cCube += IIF(cCube<>"", " - ", "")
	cChaveAtu	:=	Substr(_aDadosBlq[4], nPos, AKW->AKW_TAMANH)
	nPos		+=	AKW->AKW_TAMANH
	If !Empty(cChaveAtu)
		cCube += Alltrim(AKW->AKW_DESCRI) +" : "+ AllTrim(cChaveAtu) 
	Else
		cCube += 'Outros '
	Endif									  			
	dbSkip()
EndDo

cSayHTML :=	"<HTML><BODY><H1>"
If lOk
	cSayHTML +=	'<FONT COLOR="GREEN"  > '+ STR0080 + '</FONT > ' //"Saldo Suficiente"
Else
	cSayHTML +=	'<FONT COLOR="RED"  > '+ STR0081 + '</FONT > '//"Saldo Insuficiente"
EndIf
cSayHTML +=	"</H1>"
If nTpVersao == 5 //Smart Client versใo HTML.
    cSayHTML +=	"<FONT size=1>"
Else
    cSayHTML +=	"<FONT size=+1>"
EndIf
cSayHTML +=	STR0082 + AllTrim(AKJ->AKJ_DESCRI) + "<br>" //"Tipo de Bloqueio : "
cSayHTML +=	STR0083 + AK8->AK8_DESCRI  + "<br>" //"Processo : "
cSayHTML +=	STR0084 + AllTrim(_aDadosBlq[8]) + "<br>" //"Cubo : "
cSayHTML +=	cCube + "<br>"
cSayHTML +=	STR0085 +  Str(_aDadosBlq[2]-_aDadosBlq[3],14,2) //"Saldo necessario :"
cSayHTML +=	"</FONT> "
cSayHTML +=	"<br></BODY></HTML>"

Return cSayHTML

// Guarda o valor que ja esta empenhado ates da altera็ใo
Function PcoCtngVld()

_nVldEmpAKD := AKD->AKD_VALOR1

return

// Restaura contingencia
Function PcoCtngRes(lDel)

If lDel

	aCntgBak := {}

EndIf

Return aClone(aCntgBak)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCntgFind  บAutor  ณ Acacio Egas        บ Data ณ  09/26/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Localiza contingencias disponiveis ou bloqueadas.          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function CntgFind(lBusca, cCodBusca)

//************************************
// aCtgs = Vetor com Contignecias     *
//  [x,01]= Check box                 *
//  [x,02]= Codigo da Contingencia    *
//  [x,03]= Nome do Usuario           *
//  [x,04]= Data da Solicitacao       *
//  [x,05]= Data da Liberacao         *
//  [x,06]= Valor da Contingencia     *
//  [x,07]= Valor Empenhado           *
//  [x,08]= Total                     *
//  [x,09]= Vetor com Tabela ALI      *
//  [x,10]= Deleta do Liste			  *
//*************************************

Local aAreaAKD
Local cChaveAKD
Local nI,nX
Local _aCtgs 	:= {}
Local _aCtgsBkp := {}
Local cChave := Padr(UsrRetName(__cUserID),TamSx3("ALI_NOMSOL")[1])
Local nOrder := 4

Default lBusca 		:= .F.
Default cCodBusca	:= ""

// Controle de contingencia por chave se nใo for no modo busca
If !lBusca

	// Controle de contingencia por chave configuravel
	If ALI->(FieldPos("ALI_CHAVE"))>0 .and. AKA->(FieldPos("AKA_CHVCTG"))>0 .and. !Empty(AKA->AKA_CHVCTG)
		cChave := Padr(&(AKA->AKA_CHVCTG),Len(ALI->ALI_CHAVE))
		nOrder := 5
	EndIf

ElseIf lBusca .And. !Empty(cCodBusca)
	cChave := cCodBusca
	nOrder := 1
EndIf

DbSelectArea("ALI")
//controle de Chave
DbSetOrder( nOrder )
DbSeek( xFilial("ALI") + cChave )

If lBusca .And. !Empty(cCodBusca)
	cChave += ALI->ALI_USER
EndIf

Do While !Eof() .and. xFilial("ALI") + cChave == &(IndexKey())

	// Inclui contingencias no Vetor
	If (nI := aScan(_aCtgs, {|x| x[N_CODCTG]==ALI->ALI_CDCNTG })) == 0

		aAdd( _aCtgs , { .F. , ALI->ALI_CDCNTG , ALI->ALI_NOMSOL , ALI->ALI_DTSOLI , ALI->ALI_DTLIB , 0 , 0 , 0 , { Array(ALI->(FCount())) }, ALI_STATUS $ "04|06" } )
		aEval(_aCtgs[Len(_aCtgs),N_VETALI,1] , {|x,y| _aCtgs[Len(_aCtgs),N_VETALI,1,y] := ALI->(FieldGet(Y)) })

	Else
	
		aAdd( _aCtgs[nI,N_VETALI] , { Array( ALI->(FCount()) ) } )
		aEval(_aCtgs[nI,N_VETALI,Len(_aCtgs[nI,N_VETALI])] , {|x,y| _aCtgs[nI,N_VETALI,Len(_aCtgs[nI,N_VETALI]),y] := ALI->(FieldGet(Y)) })
		_aCtgs[nI,N_DTLIBE] := ALI->ALI_DTLIB

		//************************************
		// Controle de Contigencia cancelada *
		//************************************
		If !_aCtgs[ nI , N_DELETE ]
			_aCtgs[ nI , N_DELETE ] := (ALI_STATUS $ "04|06")
		EndIf

	EndIf		

	ALI->(DbSkip())
EndDo

// Atualiza valore da tabela ALJ
DbSelectArea("ALJ")
DbSetOrder(1)

//**************************************
// Localiza contingencias disponiveis  *
//**************************************

For nX:=1 To Len(_aCtgs)
    
		DbSelectArea("ALJ")
		If DbSeek( xFilial("ALJ") + _aCtgs[ nX , N_CODCTG ] )
		
			aAreaAKD := AKD->(GetArea())
			cChaveAKD := Padr("ALJ"+&(IndexKey())+ "01",Len(AKD->AKD_CHAVE))
			DbSelectArea("AKD")
			DbSetOrder(10)
			If !DbSeek(xFilial("AKD") + cChaveAKD )
		
				_aCtgs[ nX , N_VLRCTG ] := ALJ->ALJ_VALOR1
	
				If ALJ->(FieldPos("ALJ_EMPVAL"))>0				
	
					_aCtgs[ nX , N_VLREMP ]	:= ALJ->ALJ_EMPVAL
					_aCtgs[ nX , N_TOTCTG ] := ALJ->ALJ_EMPVAL + ALJ->ALJ_VALOR1
	
				EndIf
			
			Else
			
			    _aCtgs[ nX , N_DELETE ] := .T.

				//As conting๊ncias jแ utilizadas sใo retiradas do array de contigencias, msg para alertar usuแrio se for busca
				If lBusca .And. !Empty(cCodBusca) .And. nOrder == 1
					ApMsgInfo(STR0107, STR0108 ) // Conting๊ncia indisponํvel // A contingencia buscada nใo estแ mais disponํvel
				EndIf
		
			EndIf
			RestArea(aAreaAKD)
			
		EndIf

Next

//Apaga contingencias jแ utilizadas
For nX:=1 To Len(_aCtgs)
    
	If !_aCtgs[nX,N_DELETE]
		aAdd(_aCtgsBkp , _aCtgs[nX] )
	EndIf
	
Next

Return _aCtgsBkp

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOA530   บAutor  ณ Acacio Egas        บ Data ณ  09/29/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina de gera็ใo de Senha para contingencia do PCO        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function PcoCtngKey(cKey,nRecno,lGera)

Local xRet

Default nRecno 	:= ALJ->(Recno())
Default lGera	:= .T.     


If lGera

	xRet := Int2Hex( val( EMBARALHA( StrZero( nRecno , 6 ) ,0) ) , 6 ) 
	
Else

	xRet := ( val( Embaralha( StrZero( Hex2Int( cKey ) , 6 ) , 1 ) ) == nRecno)


EndIf

Return xRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGetAlcCtg บAutor  ณ Acacio Egas        บ Data ณ  11/04/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta array com todas os niveis de aprova็ใo e seu usuario บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function GetAlcCtg(cCodCntg)

Local aArea		:= ALI->(GetArea())
Local aRecAux 	:= {}

dbSelectArea("ALI")
DbSetOrder(1)
dbSeek(xFilial("ALI")+cCodCntg)

While !Eof() .And. xFilial("ALI")+cCodCntg == ALI_FILIAL+ALI_CDCNTG

	aAdd(aRecAux, { ALI->(Recno()), ALI->ALI_NIVEL , ALI->ALI_STATUS , ALI->ALI_USER } )
	dbSkip()
EndDo

aSort(aRecAux,,, { |x, y| x[2] < y[2] })

RestArea(aArea)

Return aRecAux


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณStrToCub  บAutor  ณ Acacio Egas        บ Data ณ  01/27/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Transforma uma chave em array de acordo com o cubo         บฑฑ
ฑฑบ          ณ gerencial.                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function StrToCub(cStrCubo,cCodCubo,lTpSald)

Local aRet 		:= {}
Local aArea 	:= AKW->(GetArea())
Local nPos
Default cCodCubo := AL1->AL1_CONFIG
Default lTpSald	:= .F.
dbSelectArea("AKW")
dbSetOrder(1)
If MsSeek(xFilial("AKW")+cCodCubo)
             

	nPos	:=	1
	While (!Eof()) .And. (AKW->AKW_FILIAL+AKW->AKW_COD == xFilial("AKW")+cCodCubo)
		If !lTpSald .and. AKW->AKW_ALIAS=="AL2"
			Exit
		EndIf
		aAdd( aRet , { SubStr(cStrCubo,nPos,AKW->AKW_TAMANH) , nPos , AKW->AKW_TAMANH  } )
		nPos		+=	AKW->AKW_TAMANH							  			
		dbSkip()
	EndDo

EndIf

RestArea(aArea)

Return aRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCO530CPY บAutor  ณ Pedro Pereira Lima บ Data ณ  16/08/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PCO530CPY(cArqOrig,cArqDest)                        
Local nHndOrig	:= 0
Local nHndDest	:= 0
Local cNewFl	:= ""

nHndOrig := FT_FUSE(cArqOrig)

If nHndOrig == -1      
	Return Nil
Else      
	FT_FGOTOP()
	While !FT_FEOF()
		cNewFl += FT_FREADLN() + CRLF
		FT_FSKIP()							
	EndDo        
	FT_FUSE()
Endif

nHndDest := FOpen(cArqDest,2)

If nHndDest == -1
	Return Nil
Else
	FWrite(nHndDest,cNewFl,Len(cNewFl))
	FClose(nHndDest)	
EndIf

FClose(cArqOrig)
FErase(cArqOrig)

Return

/*/{Protheus.doc} DlgSenha
	(long_description)
	@type  DlgSenha
	@author caio
	@since 09/03
	@version 12.1.27
	@param 
	@return 
	@example
	(examples)
	@see (links_or_references)
	/*/

Static Function DlgSenha(_aCtgs,oBrwALJ)

Local oDlg1		
Local cSenha	:= Space(6)
Local nOpca 	:= 0
Local lSenhaOK	:= .F.
Local aCtgsCopy := aClone(_aCtgs)
Local cCodBusca := ""
Local lBusca	:= .T.
//Local lRet 		:= .F.

DEFINE MSDIALOG oDlg1 TITLE STR0103 FROM 33,25 TO 110,349 PIXEL //"Busca de Contingencia por senha"
@ 01,05 TO 032, 128 OF oDlg1 PIXEL
@ 08,08 SAY STR0104 SIZE 55, 7 OF oDlg1 PIXEL // "Senha de conting๊ncia"
@ 18,08 MSGET cSenha SIZE 37, 11 OF oDlg1 PIXEL Picture "@!"  WHEN .T. VALID !Empty(cSenha)

DEFINE SBUTTON FROM 05, 132 TYPE 1 ACTION (nOpca := 1,oDlg1:End()) ENABLE OF oDlg1
DEFINE SBUTTON FROM 18, 132 TYPE 2 ACTION (nOpca := 0,oDlg1:End()) ENABLE OF oDlg1
ACTIVATE MSDIALOG oDlg1 CENTERED

// Validar se existe a contingencia pela chave
lSenhaOK := BuscaSenha(cSenha, @cCodBusca)

If lSenhaOk
	// Chamar fun็ใo que carrega conting๊ncia 
	aCtgsCopy := CntgFind(lBusca, cCodBusca)

	If !Empty(aCtgsCopy) 

		_aCtgs := aClone(aCtgsCopy)
		oBrwALJ:nAt := Len(_aCtgs)
		oBrwALJ:SetArray(_aCtgs)
		oBrwALJ:Refresh()
	EndIf

EndIf

Return 

/*/{Protheus.doc} BuscaSenha
	(long_description)
	@type  BuscaSenha
	@author caio	
	@since 09/03
	@version 12.1.27
	@param cSenha
	 param_type: caractere, 
	 param_descr: senha informada na fun็ใo DlgSenha()
	@return lRet, 
	return_type: logico, 
	return_description: Se encontrou
	@example
	(examples)
	@see (links_or_references)
	/*/

Static Function BuscaSenha(cSenha, cCodBusca)

Local lRet 		:= .F.
Local nRecno 	:= 0 

nRecno := Val( Embaralha( StrZero( Hex2Int( cSenha ) , 6 ) , 1 ) )

If nRecno > 0

	//Tabela ALJ jแ estแ ativa
	DBSelectArea("ALJ")
	//DBSetOrder(1)
	ALJ->(DbGoTo(nRecno))

	If ALJ->(Recno()) == nRecno //Se encontrou o registro
		lRet := .T.

		cCodBusca :=  ALJ->ALJ_CDCNTG //Pega o c๓digo da conting๊ncia

	Else
		ApMsgInfo(STR0106 + CRLF + CRLF + STR0111, STR0105) // "Senha Invalida" // "A senha informada nใo correspone a nenhuma conting๊ncia. Confira se digitou a senha corretamente"
	EndIf
Else
	ApMsgInfo(STR0106 + CRLF + CRLF + STR0111, STR0105) // "Senha Invalida" // "A senha informada nใo correspone a nenhuma conting๊ncia. Confira se digitou a senha corretamente"
EndIf

Return lRet

/*/{Protheus.doc} Pco530CLib
(Fun็ใo usada para controlar a contingencia liberada e selecionada)
@type  Function
@author nome
@since 20211122
@version 1.0
@return _lLibCtg //variแvel estแtica 
/*/
Function Pco530CLib()
Return _lLibCtg