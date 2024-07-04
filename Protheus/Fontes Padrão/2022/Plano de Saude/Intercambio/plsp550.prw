#INCLUDE "PLSP550.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PLSMGER.CH"

#define __aCdCri206 {"982","Bloqueio processo AJIUS"}//"Bloqueio processo AJIUS"
STATIC bCodLayPLS := .F.

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    � PLSP550    � Autor � Alexander Santos    � Data � 03.01.07 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Gera o arquivo PTU 550...                                  ����
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function PLSP550

PRIVATE cCadastro	:= STR0001
PRIVATE aRotina		:= MenuDef()
PRIVATE cMarcaBRJ	:= GetMark()
PRIVATE a550Pos		:= {}
PRIVATE cTpArq		:= ""
PRIVATE nOpcaImp	:= 0
PRIVATE	cCodMotiv	:= ""
PRIVATE	cDescriMotiv:= ""
PRIVATE cMarca 		:= GetMark( )
PRIVATE oDlg
PRIVATE nOpca		:=0
PRIVATE lInverte	:=.F.
PRIVATE aObjetos	:={}
PRIVATE dDatEFa
PRIVATE cNumFat
PRIVATE dDtVenc		:=dDatabase
PRIVATE nVlrTFa		:=0
PRIVATE cPerg := padr("PLP550",10)
PRIVATE aResumo		:={}

PRIVATE cCodCritica:= ""
PRIVATE cDesCritica:= ""

PRIVATE nOpbaixa   := 0
PRIVATE lNoMbrowse := .F.
PRIVATE cGerPtu    := GetNewPar("MV_GERPTU","0") //Parametro = 0 - Criado para versao 4.1B, NAO GERA TITULO CONTESTACAO / 1 - GERA TITULO CONTESTACAO


//�����������������������������������������������������������������������������Ŀ
//�Tratamento da critica para o bloqueios dos itens da guia glosado e que serao �
//�clonados para outra guia													    �
//�������������������������������������������������������������������������������

PLSPOSGLO(PLSINTPAD(),__aCdCri206[1],__aCdCri206[2])
cCodCritica:= BCT->BCT_PROPRI+BCT->BCT_CODGLO
cDesCritica:= BCT->BCT_DESCRI


lRet := Pergunte(cPerg,.T.)

If lRet
	//��������������������������������������������������������������������������Ŀ
	//� Importacao Reembolso 										 �
	//���������������������������������������������������������������������������� 
	If MV_PAR05 == 1    
		//��������������������������������������������������������������������������Ŀ
		//�	Atraves do BRJ enviado pelo A550 Tipo 1									 �
   		//���������������������������������������������������������������������������� 
		If MV_PAR06 == 1
			PL550ImpOr() 
		//��������������������������������������������������������������������������Ŀ
		//�	Atraves do BTO enviado pelo A550 Tipo 1									 �
   		//���������������������������������������������������������������������������� 	
		ElseIf 	MV_PAR06 == 2       
			PL550ImpEx()
		Endif
	//��������������������������������������������������������������������������Ŀ
	//� Importacao Unimed 1-Executora  											 �
	//�	Atraves do BTO											 				 �
	//����������������������������������������������������������������������������
	ElseIf MV_PAR04 = 1
   		PL550ImpEx()
	//��������������������������������������������������������������������������Ŀ
	//� Importacao Unimed 2-Origem  											 �
	//�	Atraves do BRJ enviado pelo A550 Tipo 1									 �
	//����������������������������������������������������������������������������
	ElseIf MV_PAR04 == 2
		PL550ImpOr()
	EndIf
EndIf

Return


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PL550ImpEx�Autor  �Microsiga           � Data �  03/16/12   ���
�������������������������������������������������������������������������͹��
���Desc.     �UNIMED Executora - Importa os Tipos de Arquivos 3,4,5,7 e 8 ���
��� 		 �															  ���
���          �Entrara na funcao quando o MV_PAR04 = 1 (Unimed Executora)  ���
���			 �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function PL550ImpEx()

Local aButtons := {}
//���������������������������������������������������������������������Ŀ
//� Define o tamanho da tela.                                           �
//�����������������������������������������������������������������������
aSize := MsAdvSize()
aAdd(aObjetos, {000, 000, .T., .T.})
aInfo   := {aSize[1], aSize[2], aSize[3], aSize[4], 0, 0}
aPosObj := MsObjSize(aInfo, aObjetos)

//��������������������������������������������������������������������������Ŀ
//� Seleciona a area														 �
//����������������������������������������������������������������������������
DbSelectArea("BTO")

cFiltro := "@BTO_FILIAL = '" + xFilial("BTO") + "' AND BTO_STATUS = '1'  AND D_E_L_E_T_ <> '*' "

If MV_PAR05 == 1 
	cFiltro += " AND BTO_REEANE = '1' "
Else
 	cFiltro += " AND BTO_REEANE <> '1' "
EndIf

	
SET FILTER TO &cFiltro

BTO->(MsSeek(xFilial("BTO")))

DEFINE MSDIALOG oDlg TITLE STR0047 From aSize[2]+175, aSize[1] To aSize[6], aSize[5] pixel of  GetWndDefault() //"Importa��o do PTU A550 Ajius"


//��������������������������������������������������������������������������Ŀ
//� Monta CheckBox. Marcar desmarcar todos...                                �
//����������������������������������������������������������������������������
oMark := MsSelect():New("BTO","BTO_OK",,,@lInverte,@cMarca,{aSize[2]+15,aSize[1],aSize[4]-30,aSize[3]})
oMark:bMark := {|| A550Mark(@lInverte)}
oMark:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

aAdd( aButtons, {"S4WB005N" ,{|| Pl550Excluir(2,.T.)},STR0048, STR0049 } ) //"Excluir arquivo de importa��o" //"Excluir"
aAdd( aButtons, {"S4WB005N" ,{|| Pl550PesqTit()},'Pesquisar T�tulo', 'Pesq.Tit' } )
aAdd( aButtons, {"S4WB005N" ,{|| Pl550PesqLot()},'Pesquisar Lote', 'Pesq.Lote' } ) 


//��������������������������������������������������������������������������Ŀ
//� Cria tela para selecao das faturas...			                         �
//����������������������������������������������������������������������������

ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| nOpca := 1,oDlg:End()},{|| nOpca := 0,ODlg:End()},,aButtons)

If  nOpca == 1
	PLSPA550GE()
EndIf

Return
/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    � PLSUA550GE � Autor � Alexander Santos    � Data � 02.01.07 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Gera os arquivos de importacao/cancela do ajius 			  ����
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function PLSPA550GE()
LOCAL nFor
LOCAL aRet		:= {}
LOCAL lCan 		:= .F.
LOCAL aOK   	:= {}
LOCAL cAliasTrb	:= GetNextAlias()
LOCAL aPegs		:={}
LOCAL aRegistros:={}
LOCAL i			:=0
LOCAL aFields	:={}
LOCAL lret		:=.T.
LOCAL lCancelTit:=.F.
LOCAL cErros := ""
LOCAL nVlrAcServ:= 0
LOCAL nVlrAcTax := 0 
LOCAL aAreaBTO  := {}
LOCAL cChaveBTO := ""
LOCAL cArqPar   := ""

If IsInCallStack("PL550Imp6")
	nOpcaImp := 6
EndIf
//��������������������������������������������������������������������������Ŀ
//� Monta Layout															 �
//����������������������������������������������������������������������������
MonLayout(Alltrim(mv_par01))
//��������������������������������������������������������������������������Ŀ
//� Se e reembolso                         					 �
//����������������������������������������������������������������������������
If MV_PAR05 == 1   
	aRet    	:= LerArqImp(MV_PAR02) 
	If len(aRet) > 0 
		nOpcaImp    := aRet[1]
		aMatArq 	:= aClone(aRet[2])   
		cArqPar := aRet[4]
	Else
		Return
	EndIf	
	//��������������������������������������������������������������������������Ŀ
	//� Verifica se ja foi importado o mesmo arquivo com o mesmo TP_ARQUIVO 	 �
	//����������������������������������������������������������������������������
	If MV_PAR06 == 2   
		If !ValidImp("BTO",nOpcaImp,cArqPar)   
			Return
		EndIf
	Else
		If !ValidImp("BRJ",nOpcaImp,cArqPar)   
			Return
		EndIf
    EndIf
    
	ImpReemAne(aRet[1],aMatArq,MV_PAR06,cArqPar)
	Return(.F.)      
EndIf	
//��������������������������������������������������������������������������Ŀ
//� Variavel nOpcaImp eh o retorno do TP_ARQUIVO importado					 �
//����������������������������������������������������������������������������
nOpcaImp := 0
Pergunte(padr("PLP550",10),.F.)
aRet := LerArqImp(MV_PAR02)

If len(aRet) > 0 
	If ValType(aRet) == "U"
		Return
	Else
		nOpcaImp := aRet[1]
	EndIf
	
Else
	Return
EndIf

//nValLiq  := 0
If empty(nOpcaImp) .OR. !(alltrim(STR(nOpcaImp)) $ '1|3|4|5|6|7|8')
	MsgStop(STR0052,STR0051)   //"O arquivo importado n�o � o mesmo informado no par�metro tipo de arquivo"
	Return
Endif


//��������������������������������������������������������������������������Ŀ
//� Importando como Tipo 1 - Inclusao de Questionamentos					 �
//����������������������������������������������������������������������������
If MV_PAR04 == 1
	If (BTO->BTO_TPMOV == '3' .And. BTO->BTO_TPCOB == '1') .Or. BTO->BTO_TPMOV == '1'
		BeginSql Alias cAliasTrb
			SELECT * FROM %table:BD6% BD6
			WHERE BD6.BD6_FILIAL = %exp:xFilial("BD6")% AND BD6.BD6_NUMNDC = %exp:BTO->BTO_NUMTIT% AND BD6.BD6_PRENDC = %exp:BTO->BTO_PREFIX%  AND BD6.%notDel%
		Endsql
	Else
		BeginSql Alias cAliasTrb
			SELECT * FROM %table:BD6% BD6
			WHERE BD6.BD6_FILIAL = %exp:xFilial("BD6")% AND BD6.BD6_NUMTIT = %exp:BTO->BTO_NUMTIT% AND BD6.BD6_PREFIX = %exp:BTO->BTO_PREFIX%  AND BD6.%notDel%
		Endsql
	Endif
	
	//��������������������������������������������������������������������������Ŀ
	//� Verifica se ja foi importado o mesmo arquivo com o mesmo TP_ARQUIVO 	 �
	//����������������������������������������������������������������������������
   	If  nOpcaImp == 3 .AND. BTO->BTO_NIV550 = '3' .And. BTO->BTO_ARQPAR == '2'  //Tipo 3
		MsgStop("Item j� importado como tipo 3, caso queira importar o mesmo dever� ser excluido e depois importado novamente",STR0051) //"Item j� importado como tipo 3, caso queira importar o mesmo dedever� ser excluido e depois importado novamente"
		Return
	Endif
	If  nOpcaImp == 4 .AND. BTO->BTO_NIV550 = '4' .And. BTO->BTO_ARQPAR == '2'  //Tipo 4
		MsgStop("Item j� importado como tipo 4, caso queira importar o mesmo dever� ser excluido e depois importado novamente",STR0051) //"Item j� importado como tipo 4 caso queira importar o mesmo dedever� ser excluido e depois importado novamente"
		Return
	Endif
	If  nOpcaImp == 5 .AND. BTO->BTO_NIV550 = '5'   //Tipo 5
		MsgStop("Item j� importado como tipo 5, caso queira importar o mesmo dever� ser excluido e depois importado novamente",STR0051) //"Item j� importado como tipo 5, caso queira importar o mesmo dedever� ser excluido e depois importado novamente"
		Return
	Endif
	If  nOpcaImp == 6 .AND. BTO->BTO_NIV550 = '6'   //Tipo 6
		MsgStop("Item j� importado como tipo 6, caso queira importar o mesmo dever� ser excluido e depois importado novamente",STR0051) //"Item j� importado como tipo 6, caso queira importar o mesmo dedever� ser excluido e depois importado novamente"
		Return
	Endif
	If  nOpcaImp == 7 .AND. BTO->BTO_NIV550 = '7'   //Tipo 7
		MsgStop("Item j� importado como tipo 7, caso queira importar o mesmo dever� ser excluido e depois importado novamente",STR0051) //"Item j� importado como tipo 7, caso queira importar o mesmo dedever� ser excluido e depois importado novamente"
		Return
	Endif
	If  nOpcaImp == 8 .AND. BTO->BTO_NIV550 = '8'   //Tipo 8
		MsgStop("Item j� importado como tipo 8, caso queira importar o mesmo dever� ser excluido e depois importado novamente",STR0051) //"Item j� importado como tipo 8, caso queira importar o mesmo dedever� ser excluido e depois importado novamente"
		Return
	Endif 


// Unimed 2-ORIGEM	 														 
// Por se tratar da Unimed Executora a validacao eh feita atraves da BRJ	 

ElseIf MV_PAR04 == 2

		//Verifica se ja foi importado o mesmo arquivo com o mesmo TP_ARQUIVO 
		// Nos fechamentos parciais deve ser permitido a importa��o devido ao processo do AJIUS permitir 2 parciais e 1 complementar.
		// 3 - Fechamento parcial da Unimed Credora da NDC
		// 4 - Fechamento parcial da Unimed Devedora da NDC			
		If  nOpcaImp == 3 .AND. BRJ->BRJ_NIV550 = '3' .And. BRJ->BRJ_ARQPAR == '2'   //Tipo 3
			MsgStop(STR0057+"3"+STR0058,STR0051) //"Item j� importado como tipo " ### ", caso queira importar o mesmo dever� ser excluido e depois importado novamente"
			Return
		Endif
		If  nOpcaImp == 4 .AND. BRJ->BRJ_NIV550 = '4' .And. BRJ->BRJ_ARQPAR == '2'  //Tipo 4
			MsgStop(STR0057+"4"+STR0058,STR0051) //"Item j� importado como tipo " ### ", caso queira importar o mesmo dever� ser excluido e depois importado novamente"
			Return
		Endif
		If  nOpcaImp == 5 .AND. BRJ->BRJ_NIV550 = '5'   //Tipo 5
			MsgStop(STR0050,STR0051) //"Item j� importado como tipo 5, caso queira importar o mesmo dedever� ser excluido e depois importado novamente"
			Return
		Endif
		If  nOpcaImp == 6 .AND. BRJ->BRJ_NIV550 = '6'   //Tipo 6
			MsgStop(STR0057+"6"+STR0058,STR0051) //"Item j� importado como tipo " ### ", caso queira importar o mesmo dever� ser excluido e depois importado novamente"
			Return
		Endif
		If  nOpcaImp == 7 .AND. BRJ->BRJ_NIV550 = '7'   //Tipo 7
			MsgStop(STR0057+"7"+STR0058,STR0051) //"Item j� importado como tipo " ### ", caso queira importar o mesmo dever� ser excluido e depois importado novamente"
			Return
		Endif
		If  nOpcaImp == 8 .AND. BRJ->BRJ_NIV550 = '8'   //Tipo 8
			MsgStop(STR0057+"8"+STR0058,STR0051) //"Item j� importado como tipo " ### ", caso queira importar o mesmo dever� ser excluido e depois importado novamente"
			Return
		Endif
		If  nOpcaImp == 9 .AND. BRJ->BRJ_NIV550 = '9'   //Tipo 8
			MsgStop(STR0057+"9"+STR0058,STR0051) //"Item j� importado como tipo " ### ", caso queira importar o mesmo dever� ser excluido e depois importado novamente"
			Return
		Endif
		//��������������������������������������������������������������������������Ŀ
		//� Realiza mais algumas verificacoes com o BRJ_NIV550                  	 �
		//����������������������������������������������������������������������������
		Do Case
	   		Case cValToChar(nOpcaImp) $ '3/4/5/6'
	  			If BRJ->BRJ_NIV550 <> '1'
	  				If BRJ->BRJ_NIV550 == '3' .And. BRJ->BRJ_ARQPAR == '2'
		  			MsgStop(STR0059+"1",STR0051)//"Para importar este arquivo, o Nivel A550 desta importa��o deve ser "
		  			Return
				EndIf
				EndIf
    		Case cValToChar(nOpcaImp) $ '7/8'
    			If BRJ->BRJ_NIV550 $ '5/6'
					MsgStop(STR0059+"3 ou 4",STR0051) //"Para importar este arquivo, o Nivel A550 desta importa��o deve ser "
					Return
				EndIf
		EndCase

		//������������������������������������������������������Ŀ
		//� Query									 			 �
		//��������������������������������������������������������
		BeginSql Alias cAliasTrb

			SELECT * FROM %table:BD6% BD6
			WHERE BD6.BD6_FILIAL = %exp:xFilial("BD6")%  AND
			BD6.BD6_SEQIMP = %exp:BRJ->BRJ_CODIGO%
			AND BD6.%notDel%
			ORDER BY BD6_FILIAL,BD6_CODOPE,BD6_CODLDP,BD6_CODPEG,BD6_NUMERO,BD6_SEQUEN,BD6_CODPAD,BD6_CODPRO
		Endsql

EndIf

If (cAliasTrb)->(!Eof())
	While (cAliasTrb)->(!Eof())
		IF Ascan(aPegs,{|x| x[1]+x[2]+x[3]+x[5] == (cAliasTrb)->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO)})=0
			aadd(aPegs,{(cAliasTrb)->BD6_CODOPE,(cAliasTrb)->BD6_CODLDP,(cAliasTrb)->BD6_CODPEG,(cAliasTrb)->BD6_TIPGUI,(cAliasTrb)->BD6_NUMERO})
		Endif
		(cAliasTrb)->(DbSkip())
	Enddo
Endif


(cAliasTrb)->(DbGotop())
If (cAliasTrb)->(!Eof())
	While (cAliasTrb)->(!Eof())
		aadd(aRegistros,{(cAliasTrb)->BD6_CODOPE,(cAliasTrb)->BD6_CODLDP,(cAliasTrb)->BD6_CODPEG,(cAliasTrb)->BD6_TIPGUI,(cAliasTrb)->(RECNO())})
		(cAliasTrb)->(DbSkip())
	Enddo
Endif

aRet    	:= LerArqImp(MV_PAR02)

If len(aRet) > 0 
	aMatArq 	:= aClone(aRet[2])
	aCriticas 	:= aClone(aRet[3])
	cArqPar 	:= aRet[4]	
Else
	Return
Endif

If Len(aMatArq)> 0
	For i:=1 to Len(aPegs)
		If aPegs[i,4] $ "01,02,04,06,  "
			BD5->( DbSetOrder(1) ) //BD5_FILIAL, BD5_CODOPE, BD5_CODLDP, BD5_CODPEG, BD5_NUMERO, BD5_SITUAC, BD5_FASE, BD5_DATPRO, BD5_OPERDA, BD5_CODRDA, R_E_C_N_O_, D_E_L_E_T_
			BD5->(dBGotop())
			If BD5->( DbSeek( xFilial("BD5")+ aPegs[i,1]+ aPegs[i,2]+ aPegs[i,3]+ aPegs[i,5]) )
				lret := PLSA550CLO("BD5",BD5->(RECNO()),3,aFields,.T.,aMatArq,nOpcaImp,@cErros,@nVlrAcServ,@nVlrAcTax,cArqPar)
			Endif
		Else
			BE4->( DbSetOrder(1) ) //BE4_FILIAL + BE4_CODOPE + BE4_CODLDP + BE4_CODPEG + BE4_NUMERO + BE4_SITUAC + BE4_FASE
			BE4->(dBGotop())
			If BE4->( DbSeek( xFilial("BE4")+aPegs[i,1]+ aPegs[i,2]+ aPegs[i,3]+ aPegs[i,5] ) )
				lret := PLSA550CLO("BE4",BE4->(RECNO()),3,aFields,.T.,aMatArq,nOpcaImp,@cErros,@nVlrAcServ,@nVlrAcTax,cArqPar)
			Endif
		Endif
	Next i
Endif
(cAliasTrb)->(DbCloseArea())

If !Empty(cErros)
	//exibe as guias com inconsist�ncias
	MsgInfo("Foram encontradas inconsist�ncias: " + CRLF + CRLF + cErros)
	//cancela as pegs clonadas
	Pl550Excluir(1,.T.)
Else
	
	//��������������������������������������������������������������������������Ŀ
	//� Marca saldos para geracao do titulo de contestacao     					 �
	//����������������������������������������������������������������������������        
	If BTO->BTO_TPMOV == "1" //1=NDC     
		BTO->( RecLock("BTO",.F.) )	
			If alltrim(STR(nOpcaImp)) $ "3/4/5/6"
				//��������������������������������������������������������������������������Ŀ
				//� PTU 7.0 grava campos de valores do Parcial 2 separadamente				 �
				//����������������������������������������������������������������������������  
				If Alltrim(mv_par01) >= "A550G" .And. alltrim(STR(nOpcaImp)) $ "3/4" .And. cArqPar == "2"
					BTO->BTO_SLDGP2  := nVlrAcServ 	
				Else	
					BTO->BTO_SLDGPF  := nVlrAcServ 
				EndIf	
				
		    ElseIf alltrim(STR(nOpcaImp)) $ "7/8" 
			    BTO->BTO_SLDGCO  := nVlrAcServ 
		    EndIf  
		    BTO->BTO_NIV550 := alltrim(STR(nOpcaImp))
		   	
		   	If Alltrim(mv_par01) >= "A550G" .And. Alltrim(STR(nOpcaImp)) $ "34"  
				BTO->BTO_ARQPAR := cArqPar
			EndIf                             
		
	    BTO->( MsUnLock() )
		
	ElseIf Empty(BTO->BTO_TPMOV) .Or. BTO->BTO_TPMOV == "2" //2=Fatura     
		BTO->( RecLock("BTO",.F.) )	
			If alltrim(STR(nOpcaImp)) $ "3/4/5/6"
				//��������������������������������������������������������������������������Ŀ
				//� PTU 7.0 grava campos de valores do Parcial 2 separadamente				 �
				//����������������������������������������������������������������������������  
				If Alltrim(mv_par01) >= "A550G" .And. alltrim(STR(nOpcaImp)) $ "3/4" .And. cArqPar == "2"
					BTO->BTO_SLDGP2  := nVlrAcServ+nVlrAcTax 
				Else	
					BTO->BTO_SLDGPF  := nVlrAcServ+nVlrAcTax 
				EndIf	
				
		    ElseIf alltrim(STR(nOpcaImp)) $ "7/8" 
			    BTO->BTO_SLDGCO  := nVlrAcServ+nVlrAcTax 
		    EndIf 
		    BTO->BTO_NIV550 := alltrim(STR(nOpcaImp))

	     	If Alltrim(mv_par01) >= "A550G" .And. Alltrim(STR(nOpcaImp)) $ "34" 
				BTO->BTO_ARQPAR := cArqPar
			EndIf 
				                            
	    BTO->( MsUnLock() )
	ElseIf BTO->BTO_TPMOV == "3" //3=Ambos  
		//Quando o Faturamento e para Ambos, vao existir dos BTOs
		aAreaBTO := BTO->(GetArea())
		BTO->(DbSetOrder(1))//BTO_FILIAL + BTO_CODOPE + BTO_NUMERO + BTO_OPEORI
		cChaveBTO := BTO->(BTO_FILIAL + BTO_CODOPE + BTO_NUMERO + BTO_OPEORI)
		If BTO->(DbSeek(cChaveBTO)) 
			  
			While BTO->(BTO_FILIAL + BTO_CODOPE + BTO_NUMERO + BTO_OPEORI) == cChaveBTO .And. !BTO->(Eof()) 
			   	BTO->( RecLock("BTO",.F.) )
			   	//��������������������������������������������������������������������������Ŀ    
		   		//� Nova regra manual de intercambio (Flaga o BTO_TPMOV)   					 �
				//� 2 = DOC_1 (Valor do Item + Taxa Administrativa)     					 �
				//� 3 = DOC_1 (Taxa Administrativa) + DOC_2 (Valor do Item)					 �
				//����������������������������������������������������������������������������     
				If BTO->BTO_TPCOB == "1" //NDC-Servicos -> DOC2
					If alltrim(STR(nOpcaImp)) $ "3/4/5/6"
							//��������������������������������������������������������������������������Ŀ
							//� PTU 7.0 grava campos de valores do Parcial 2 separadamente				 �
							//����������������������������������������������������������������������������  
							If Alltrim(mv_par01) >= "A550G" .And. alltrim(STR(nOpcaImp)) $ "3/4" .And. cArqPar == "2"
								BTO->BTO_SLDGP2  := nVlrAcServ 	
							Else	
								BTO->BTO_SLDGPF  := nVlrAcServ 
							EndIf	
				  				
		   				ElseIf alltrim(STR(nOpcaImp)) $ "7/8" 
			   				BTO->BTO_SLDGCO  := nVlrAcServ
		   				EndIf 	
					    
				    ElseIf BTO->BTO_TPCOB == "2" //Fatura-Taxas -> DOC1	  
				    	If alltrim(STR(nOpcaImp)) $ "3/4/5/6"
				    		//��������������������������������������������������������������������������Ŀ
							//� PTU 7.0 grava campos de valores do Parcial 2 separadamente				 �
							//����������������������������������������������������������������������������  
							If Alltrim(mv_par01) >= "A550G" .And. alltrim(STR(nOpcaImp)) $ "3/4" .And. cArqPar == "2"
								BTO->BTO_SLDGP2  := nVlrAcTax 
							Else	
								BTO->BTO_SLDGPF  := nVlrAcTax  
							EndIf	
				  				
		   				ElseIf alltrim(STR(nOpcaImp)) $ "7/8" 
			   				BTO->BTO_SLDGCO  := nVlrAcTax 
		   				EndIf 	
				    EndIf   
					    
				    BTO->BTO_NIV550 := alltrim(STR(nOpcaImp))  
				
			     	If Alltrim(mv_par01) >= "A550G" .And. Alltrim(STR(nOpcaImp)) $ "34"
						BTO->BTO_ARQPAR := cArqPar
					EndIf                             
				    
			    BTO->( MsUnLock() )
				BTO->(DbSkip())
			EndDo
		EndIf	
	    RestArea(aAreaBTO)
	EndIf  		
	TelaResumo()
	//��������������������������������������������������������������������������Ŀ
	//� Verifica se ira baixar os titulos de contestacao     					 �
	//����������������������������������������������������������������������������
	If nOpcaImp == 6 //.And. MV_PAR04 == 2
		SE1->(DbSetOrder(1))//E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
		cSql := " SELECT SUM(BD7_VLRGLO) VLRGLO FROM "+RetSqlName("BD6")+" BD6, "+RetSqlName("BD7")+" BD7 "
		cSql += " WHERE BD7_FILIAL = '"+xFilial("BD7")+"' AND BD6_FILIAL = '"+xFilial("BD6")+"' "
		cSql += " AND BD7_FILIAL = BD6_FILIAL "
		cSql += " AND BD7_CODOPE = BD6_CODOPE "
		cSql += " AND BD7_CODLDP = BD6_CODLDP "
		cSql += " AND BD7_CODPEG = BD6_CODPEG "
		cSql += " AND BD7_NUMERO = BD6_NUMERO "
		cSql += " AND BD7_ORIMOV = BD6_ORIMOV "
	 	cSql += " AND BD7_BLOPAG <> '1'  "
	 	cSql += " AND BD7_SEQUEN = BD6_SEQUEN  "
	 	cSql += " AND BD6_GUIORI <> ' ' "
	 	cSql += " AND BD6.D_E_L_E_T_ = ' ' "
	 	cSql += " AND BD7.D_E_L_E_T_ = ' ' "
	    cSql +=	" AND BD7_SEQIMP = '"+BRJ->BRJ_CODIGO+"' "

	    cSql := ChangeQuery(cSql)
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"VLRGLO",.F.,.T.)

		DbSelectArea("VLRGLO")
		If !VLRGLO->(Eof())
			If VLRGLO->VLRGLO == 0
				lCancelTit := .T.
			EndIf
		EndIf

	    VLRGLO->(DbCloseArea())

		//��������������������������������������������������������������������������Ŀ
		//� Unimed Origem 									     					 �
		//����������������������������������������������������������������������������
	    If MV_PAR04 == 2
		If !Empty(BRJ->(BRJ_PREFIX+BRJ_NUMTIT+BRJ_PARCEL+BRJ_TIPTIT)) .And. lCancelTit
			If SE1->(DbSeek(xFilial("SE1")+BRJ->(BRJ_PREFIX+BRJ_NUMTIT+BRJ_PARCEL+BRJ_TIPTIT)))
				PLP550BXCA()
				MsgInfo("T�tulo de contesta��o "+BRJ->BRJ_PREFIX+" "+BRJ->BRJ_NUMTIT+" "+BRJ->BRJ_TIPTIT+" baixado por cancelamento.")
			Else
			    MsgInfo("T�tulo de contesta��o "+BRJ->BRJ_PREFIX+" "+BRJ->BRJ_NUMTIT+" "+BRJ->BRJ_TIPTIT+" n�o encontrado.")
			EndIf
		EndIf

		If !Empty(BRJ->(BRJ_PRENDC+BRJ_NUMNDC+BRJ_PARNDC+BRJ_TIPNDC)) .And. lCancelTit
			If SE1->(DbSeek(xFilial("SE1")+BRJ->(BRJ_PRENDC+BRJ_NUMNDC+BRJ_PARNDC+BRJ_TIPNDC)))
				PLP550BXCA()
				MsgInfo("T�tulo de contesta��o "+BRJ->BRJ_PRENDC+" "+BRJ->BRJ_NUMNDC+" "+BRJ->BRJ_TIPNDC+" baixado por cancelamento.")
			Else
			    MsgInfo("T�tulo de contesta��o "+BRJ->BRJ_PRENDC+" "+BRJ->BRJ_NUMNDC+" "+BRJ->BRJ_TIPNDC+" n�o encontrado.")
			EndIf
		EndIf
		EndIf
		//��������������������������������������������������������������������������Ŀ
		//� Unimed Executora 									     				 �
		//����������������������������������������������������������������������������
	    If MV_PAR04 == 1
			If!Empty(BTO->(BTO_PREFIX+BTO_NUMTIT+BTO_PARCEL+BTO_TIPTIT)) .And. lCancelTit
				If SE1->(DbSeek(xFilial("SE1")+BTO->(BTO_PREFIX+BTO_NUMTIT+BTO_PARCEL+BTO_TIPTIT)))
					PLP550BXCA()
					MsgInfo("T�tulo de contesta��o "+BTO->BTO_PREFIX+" "+BTO->BTO_NUMTIT+" "+BTO->BTO_TIPTIT+" baixado por cancelamento.")
	   			Else
					MsgInfo("T�tulo de contesta��o "+BTO->BTO_PREFIX+" "+BTO->BTO_NUMTIT+" "+BTO->BTO_TIPTIT+" n�o encontrado. ")
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

Return .T.
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �LerArqImp � Autor � Alexander Santos      � Data � 03.01.07 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Leitura do arquivo de importacao							  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function LerArqImp(cDirFile)
Local nPos
Local dDatGer
Local aQuest  	:= {}
Local aCriticas := {}
Local nTotQ552 	:= 0
Local nTotCob  	:= 0
Local nTotReq  	:= 0
Local nTotAco  	:= 0
Local nTotCab  	:= 0
Local nTotTra  	:= 0
Local cCodEdi   := ""
Local lFindDePa := .F.      
Local lDePara   := GetNewPar("MV_P500HDP","1") == "1" .And. mv_par04 == 2
Local lDeParaBTU := GetNewPar("MV_PLAJBTU","0") == "1"
Local aRetBTU   := {}
Local lNewArray := .T.
Local cArqPar   := ""
Local lPLPRO550 := ExistBlock("PLPRO550")
//��������������������������������������������������������������������������Ŀ
//� Abre o arquivo															 �
//����������������������������������������������������������������������������
//FT_FUSE(cDirFile)
//��������������������������������������������������������������������������Ŀ
//� Verifica se o arquivo esta correto para importacao						 �
//����������������������������������������������������������������������������
If FT_FUSE(cDirFile) == -1
	MsgStop("N�o foi encontrado o arquivo " + cDirFile + CHR(13)+CHR(10) +"Favor revisar!")
	Return({})
//	Exit
EndIf

While !FT_FEOF()
	//��������������������������������������������������������������������������Ŀ
	//� Pega a linha															 �
	//����������������������������������������������������������������������������
	cLinha := FT_FREADLN()
	//��������������������������������������������������������������������������Ŀ
	//� Header																	 �
	//����������������������������������������������������������������������������
	If SubStr(cLinha,09,03) == "551"
		cOpeDes := PLSA550GCF("R551","CD_UNI_DES") 				//SubStr( cLinha,12,04 )			//CD_UNI_DES - B2A_OPEDES
		dDatGer := PLSA550GCF("R551","DT_GERACAO")				//DT_GERACAO - B2A_DTGERA
		cNumFat := PLSA550GCF("R551",Iif(!bCodLayPLS,"NR_FATURA","NR_DOC_1_A")) 				//SubStr( cLinha,43,11 )			//NR_FATURA  - B2A_NUMTIT
		dDatEFa := Stod(PLSA550GCF("R551","DT_GERACAO")) 		//StoD( SubStr(cLinha,54,08) )	//DT_EMI_FAT - B2A_DTEMFA
		dDtVenc := Stod(PLSA550GCF("R551",Iif(!bCodLayPLS,"DT_VENC_FA","DT_VEN_DA1"))) 		//StoD( SubStr(cLinha,54,08) )	//DT_EMI_FAT - B2A_DTEMFA
		nVlrTFa := Val(PLSA550GCF("R551",Iif(!bCodLayPLS,"VL_TOT_FAT","VL_TOT_DA1")))/100  	//Val( SubStr(cLinha,62,14) )		//VL_TOT_FAT - B2A_VLTOTF
		cTpArq  := PLSA550GCF("R551","TP_ARQUIVO")				 //SubStr( cLinha,104,01 )			//TP_ARQUIVO - B2A_TPARQ
		cArqPar := PLSA550GCF("R551","TP_ARQ_PAR")

		//MV_PAR03=		tipo de arquivo 1 -Inclusao de quest /5 - Fechamento credor/6 - fechamento devedor
		//MV_PAR05=		Quem esta importando executora ou origem

		nTotCab++
		//��������������������������������������������������������������������������Ŀ
		//� Questionamento															 �
		//����������������������������������������������������������������������������
	ElseIf SubStr(cLinha,09,03) == "552"
		//��������������������������������������������������������������������������Ŀ
		//� Cria linha na matriz													 �
		//����������������������������������������������������������������������������
		AaDd(aQuest,Array(43))
		nPos := Len(aQuest)
		//��������������������������������������������������������������������������Ŀ
		//� Alimenta linha															 �
		//����������������������������������������������������������������������������
		aQuest[nPos,01] := PLSA550GCF("R552","NR_SEQ")
		aQuest[nPos,02] := PLSA550GCF("R552","TP_REG")
		aQuest[nPos,03] := PLSA550GCF("R552","NR_LOTE")
		aQuest[nPos,04] := PLSA550GCF("R552","RESERVADO")
		aQuest[nPos,05] := PLSA550GCF("R552","NR_NOTA")
		aQuest[nPos,06] := PLSA550GCF("R552","CD_UNI")
		aQuest[nPos,07] := PLSA550GCF("R552","ID_BENEF")
		aQuest[nPos,08] := PLSA550GCF("R552","NM_BENEF")
		aQuest[nPos,09] := Stod(PLSA550GCF("R552","DT_ATEND"))
		aQuest[nPos,10] := PLSA550GCF("R552","RESERVADO2")
		aQuest[nPos,11] := PLSA550GCF("R552","TP_TABELA")
		cCodEdi := PLSA550GCF("R552","CD_SERVICO")

	    If lPLPRO550
	    	aQuest[nPos,12] := ExecBlock("PLPRO550",.F.,.F.,{BRJ->BRJ_CODIGO,cCodEdi,PLSA550GCF("R552","NR_SEQ_500")})
		Else
			lFindDePa := .F.
			//�����������������������������������������������������������������������������������������������������Ŀ
			//� De-Para de eventos atraves da BTU                                          			                �
			//�������������������������������������������������������������������������������������������������������
			If lDeParaBTU
 				aRetBTU := PTUDePaBTU(aQuest[nPos,11],cCodEdi,nil,.T.,.F.)
				If len(aRetBTU) > 0
					cCodEdi   := aRetBTU[2]
					lFindDePa := .T.
				Endif
			//�����������������������������������������������������������������������������������������������������Ŀ
			//� Vou utilizar primeiramente a funcao PLDeParINT para utilizar o De/Para com vigencia                 �
			//�������������������������������������������������������������������������������������������������������  	 
			ElseIf lDePara
				cCodEdi := PLDeParINT(nil,cCodEdi,Stod(PLSA550GCF("R552","DT_SERVICO")),@lFindDePa,"R")
		    EndIf
			If lFindDePa
				aQuest[nPos,12] := cCodEdi 	
			Else  
				//�����������������������������������������������������������������������������������������������������Ŀ
				//� Verifica se no arquivo importado possui o codigo no campo BR8_CODPSA, caso nao tenha, verificara    �
				//�  no campo BR8_CODEDI, caso encontrou, alimentara o campo com o valor do campo BR8_CODPSA.           �
				//�������������������������������������������������������������������������������������������������������  
				BR8->(DbSetOrder(3))  // BR8_FILIAL + BR8_CODPSA + BR8_CODPAD
				If BR8->(MsSeek(xFilial("BR8")+cCodEdi))
					aQuest[nPos,12] := BR8->BR8_CODPSA
				ElseIf lDePara
					BR8->(DbSetOrder(5)) // BR8_FILIAL + BR8_CODEDI
					If BR8->(MsSeek(xFilial("BR8")+cCodEdi))
						aQuest[nPos,12] := BR8->BR8_CODPSA
					Endif
				Endif 
			EndIf	
        EndIf

		aQuest[nPos,13] := Val(PLSA550GCF("R552","VL_COBRADO"))/100
		aQuest[nPos,14] := Val(PLSA550GCF("R552","VL_RECONHE"))/100
		aQuest[nPos,15] := Val(PLSA550GCF("R552","VL_ACORDO"))/100
		aQuest[nPos,16] := Stod(PLSA550GCF("R552","DT_ACORDO"))
		aQuest[nPos,17] := PLSA550GCF("R552","TP_ACORDO")
		aQuest[nPos,18] := Val(Subs(PLSA550GCF("R552","QTD_COBRAD"),1,4)+"."+Subs(PLSA550GCF("R552","QTD_COBRAD"),5,4))
		aQuest[nPos,19] := PLSA550GCF("R552","DS_SERVICO")
		aQuest[nPos,20] := PLSA550GCF("R552","NR_SEQ_500")
		aQuest[nPos,21] := Val(PLSA550GCF("R552","VL_COBR_CO"))/100
		aQuest[nPos,22] := Val(PLSA550GCF("R552","VL_RECO_CO"))/100
		aQuest[nPos,23] := Val(PLSA550GCF("R552","VL_ACOR_CO"))/100
		aQuest[nPos,24] := Val(PLSA550GCF("R552","VL_COB_FI"))/100
		aQuest[nPos,25] := Val(PLSA550GCF("R552","VL_RECO_FI"))/100
		aQuest[nPos,26] := Val(PLSA550GCF("R552","VL_ACOR_FI"))/100
		aQuest[nPos,27] := Val(PLSA550GCF("R552","VL_CB_AD_S"))/100
		aQuest[nPos,28] := Val(PLSA550GCF("R552","VL_RE_AD_S"))/100
		aQuest[nPos,29] := Val(PLSA550GCF("R552","V_ACO_AD_S"))/100
		aQuest[nPos,30] := Val(PLSA550GCF("R552","V_CB_AD_CO"))/100
		aQuest[nPos,31] := Val(PLSA550GCF("R552","V_RE_AD_CO"))/100
		aQuest[nPos,32] := Val(PLSA550GCF("R552","V_ACD_A_CO"))/100
		aQuest[nPos,33] := Val(PLSA550GCF("R552","V_CB_AD_FI"))/100
		aQuest[nPos,34] := Val(PLSA550GCF("R552","V_RC_AD_FI"))/100
		aQuest[nPos,35] := Val(PLSA550GCF("R552","V_ACD_A_FI"))/100
		aQuest[nPos,36] := Val(Subs(PLSA550GCF("R552","QT_RECONH"),1,4)+"."+Subs(PLSA550GCF("R552","QT_RECONH"),5,4))

		aQuest[nPos,37] := Val(PLSA550GCF("R552","ID_PACOTE"))
		aQuest[nPos,38] := Val(PLSA550GCF("R552","CD_PACOTE"))
		aQuest[nPos,39] := Val(PLSA550GCF("R552","DT_SERVICO"))
		aQuest[nPos,40] := Val(PLSA550GCF("R552","HR_REALIZ"))

		aQuest[nPos,41] := Val(PLSA550GCF("R552","QT_ACORDAD"))
  		aQuest[nPos,42] := Val(PLSA550GCF("R552","FT_MULT_SV"))/100
  		aQuest[nPos,43] := PLSA550GCF("R552","NR_LOTE") //Ja utilizado tambem na posicao 05
		
		//��������������������������������������������������������������������������Ŀ
		//� Motivos de questionamento												 �
		//����������������������������������������������������������������������������
	ElseIf SubStr(cLinha,09,03) == "553"
		cCodMotiv    := PLSA550GCF("R553","CD_MOT_QUE")
		cDescriMotiv := PLSA550GCF("R553","DS_MOT_QUE")
        
        If MV_PAR05 == 1 //Reembolso      
        	//��������������������������������������������������������������������������Ŀ
			//� Cria linha na matriz													 �
			//����������������������������������������������������������������������������
			If lNewArray
				AaDd(aQuest,Array(43))
				nPos      := Len(aQuest)   
				lNewArray := .F. 
			EndIf  
		
			If Val(cCodMotiv) == 99        //ITENS N�O CONTESTADO
		  		aQuest[nPos,4] := "N"
	 		Else
		  		aQuest[nPos,4] := "S"
	   		Endif
		Else	
	
			If Val(cCodMotiv) == 99        //ITENS N�O CONTESTADO
				aQuest[nPos,37] := "N"
			Else
				aQuest[nPos,37] := "S"
			Endif
        EndIf
   		//��������������������������������������������������������������������������Ŀ
		//� Reembolso 												 �
		//����������������������������������������������������������������������������
	ElseIf SubStr(cLinha,09,03) == "558"       
		lNewArray := .T. 
		nPos      := Len(aQuest)
	                 
		aQuest[nPos,1] := PLSA550GCF("R558","NR_SEQ_500")
    	aQuest[nPos,2] := Val(PLSA550GCF("R558","VL_RECONH"))/100
    	aQuest[nPos,3] := Val(PLSA550GCF("R558","VL_ACORDO"))/100     
    	aQuest[nPos,5] := PLSA550GCF("R558","TP_ACORDO") 
    	aQuest[nPos,6] := PLSA550GCF("R558","NR_NOTA")
		//��������������������������������������������������������������������������Ŀ
		//� Trailler																 �
		//����������������������������������������������������������������������������
	ElseIf SubStr(cLinha,09,03) == "559"
		nTotQ552 := Val(PLSA550GCF("R559","QT_TOTR552"))				//Val( SubStr(cLinha,12,05) )              	//QT_TOTR552 	- B2A_NTOTRE
		nTotCob  := Val(PLSA550GCF("R559","VL_TOT_COB"))/100			//VL_TOT_COB  	- B2A_VLTCOB
		nTotReq  := Val(PLSA550GCF("R559","VL_TOT_REQ"))/100			//VL_TOT_REQ   	- B2A_VLTREI
		nTotAco  := Val(PLSA550GCF("R559","VL_TOT_ACO"))/100			//VL_TOT_ACO  	- B2A_VLTACI
		nTotTra++
	EndIf
	//��������������������������������������������������������������������������Ŀ
	//� Proximo																	 �
	//����������������������������������������������������������������������������
	FT_FSkip()
EndDo
//��������������������������������������������������������������������������Ŀ
//� Fecha arquivo														  	 �
//����������������������������������������������������������������������������
FT_FUSE()


Return( {val(cTpArq),aQuest,aCriticas,cArqPar} )

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �PLSPA550MR� Autor � Alexander Santos    � Data � 05.01.2007 ���
�������������������������������������������������������������������������Ĵ��
���Descri??o � Cria uma vida para os marcados...                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function PLSPA550MR()
LOCAL lRet :=	.F.
LOCAL nX   :=	0

//��������������������������������������������������������������������������Ŀ
//� Executa tratamento para marcar...                                        �
//����������������������������������������������������������������������������
DbSelectArea("BRJ")
//��������������������������������������������������������������������������Ŀ
//� Checa se esta marcado													 �
//����������������������������������������������������������������������������
If IsMark("BRJ_OK",cMarcaBRJ)
	BRJ->( RecLock("BRJ",.F.) )
	BRJ->BRJ_OK := ""
	BRJ->( MsUnLock() )
Else
	For nX	:=	0	To 1 STEP 0.2
		BRJ->( RecLock("BRJ",.F.) )
		BRJ->BRJ_OK := cMarcaBRJ
		BRJ->( MsUnLock() )
		nX	 :=	1
		lRet :=	.T.
	Next
	If !lRet
		MsgAlert( OemToAnsi(STR0012) ) //"Este registro esta em uso"
	EndIf
Endif

Return
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � PLSP550ARQ � Autor � Alexander Santos  � Data � 05.01.2007 ���
�������������������������������������������������������������������������Ĵ��
���Descri??o � Possibilita selectionar um diretorio+arquivo				  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function PLSP550ARQ()
LOCAL cArqImp

cArqImp := cGetFile("*.*","Selecione o Arquivo",0,"SERVIDOR\",.T.,GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_NETWORKDRIVE) //"Selecione o Arquivo"

Return(cArqImp)


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Darcio R. Sporl       � Data �09/01/2007���
�������������������������������������������������������������������������Ĵ��
���Descri??o � Utilizacao de menu Funcional                               ���
���          �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Array com opcoes da rotina.                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Parametros do array a Rotina:                               ���
���          �1. Nome a aparecer no cabecalho                             ���
���          �2. Nome da Rotina associada                                 ���
���          �3. Reservado                                                ���
���          �4. Tipo de Transa??o a ser efetuada:                        ���
���          �		1 - Pesquisa e Posiciona em um Banco de Dados         ���
���          �    2 - Simplesmente Mostra os Campos                       ���
���          �    3 - Inclui registros no Bancos de Dados                 ���
���          �    4 - Altera o registro corrente                          ���
���          �    5 - Remove o registro corrente do Banco de Dados        ���
���          �5. Nivel de acesso                                          ���
���          �6. Habilita Menu Funcional                                  ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()

PRIVATE aRotina   := {	{ STR0002, 'AxPesqui'		, 0, K_Pesquisar  , 0, .F.},; //"Pesquisar"
{ STR0003, 'PLSUA550VS'		, 0, K_Visualizar , 0, Nil},; //"Visualizar"
{ STR0004, 'PLSPA550GE()'	, 0, K_Incluir    , 0, Nil},; //"Importar"
{ STR0005, 'Pl550Excluir(1,.T.)'	, 0, K_Incluir    , 0, Nil} } //"Cancelar"

Return(aRotina)


/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
��� Programa  � PLSA500GCF � Autor � Tulio Cesar        � Data � 17.01.2005 ���
���������������������������������������������������������������������������Ĵ��
��� Descri??o � Retorna um determinado dado a partir do layout/arq. de trab.���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function PLSA550GCF(cTipReg,cDado,cSeq)
LOCAL nPos
LOCAL cRet   := ""
DEFAULT cSeq := ""

nPos := Ascan( a550Pos , {  | x | x[1] == cTipReg .And. (x[2] == cDado .or. alltrim(x[6]) == alltrim(cSeq)) } )
If nPos > 0
	cRet := Subs(clinha,a550Pos[nPos,3],(a550Pos[nPos,4]-a550Pos[nPos,3])+1)
Else
	cRet :=""
Endif

Return(cRet)

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
��� Programa  � MonLayout  � Autor � Tulio Cesar        � Data � 17.01.2005 ���
���������������������������������������������������������������������������Ĵ��
��� Descri??o � Monta matriz de apoio com todos os layouts do respectivo EDI���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function MonLayout(cLayPLS)

bCodLayPLS := cLayPLS >= "5.0a"

DE1->(DbSetOrder(1))
If DE1->(MsSeek(xFilial("DE1")+cLayPLS))
	While ! DE1->(Eof()) .And. DE1->DE1_FILIAL == xFilial("DE1") .And. Alltrim(DE1->DE1_CODLAY) == cLayPLS
		aadd(a550Pos,{AllTrim(DE1->DE1_CODREG),AllTrim(DE1->DE1_CAMPO),Val(DE1->DE1_POSINI),Val(DE1->DE1_POSFIM), Val(DE1->DE1_POSFIM)-Val(DE1->DE1_POSINI)+1,DE1->DE1_SEQUEN})
		DE1->(DbSkip())
	Enddo
Endif

Return


/*/
�������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
��� Funcao   � A500MARK� Autor � Thiago Machado Correa � Data � 25.10.2004 ���
��������������������������������������������������������������������������Ĵ��
���Descri??o � Marca/Desmarca todos os itens do Browse...                  ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/

Function A550Mark(lInverte)


nRecnoBTO:=BTO->( RECNO())

BTO->(DbGoTop())
BTO->(MsSeek(xFilial("BTO")))

/*While BTO->(!Eof())
	BTO->( RecLock("BTO",.F.) )
	BTO->BTO_OK := ""
	BTO->( MsUnLock() )
	BTO->(DbSkip())
Enddo   */
LimpaBTO()

BTO->(DbGoTo(nRecnoBTO))

If lInverte
	BTO->( RecLock("BTO",.F.) )
	BTO->BTO_OK := ""
	BTO->( MsUnLock() )
	lInverte:=.F.
Else
	BTO->( RecLock("BTO",.F.) )
	BTO->BTO_OK := cMarca
	BTO->( MsUnLock() )
	lInverte:=.T.
Endif

oMark:oBrowse:Refresh()


Return

Function LimpaBTO()

cQuery := "UPDATE "+RetSqlName("BTO")+ " SET BTO_OK = ' ' WHERE BTO_FILIAL = '" + xFilial("BTO") + "' AND D_E_L_E_T_ = ' ' "

TCSQLEXEC(cQuery)

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PLSA550CLO�Autor  �Microsiga           � Data �  03/13/12   ���
�������������������������������������������������������������������������͹��
���Desc.     �Clonagem das guias do 550                                   ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function PLSA550CLO(cAlias,nReg,nOpc,aFields,lMsg,aMatArq,nOpcaImp,cErros,nVlrAcServ,nVlrAcTax,cArqPar)

LOCAL cChaveGui:= &(cAlias+"->("+cAlias+"_CODOPE+"+cAlias+"_CODLDP+"+cAlias+"_CODPEG+"+cAlias+"_NUMERO+"+cAlias+"_ORIMOV)")
Local cChaveBe4:= &(cAlias+"->("+cAlias+"_CODOPE+"+cAlias+"_CODLDP+"+cAlias+"_CODPEG+"+cAlias+"_NUMERO)")
LOCAL aCabec   := {cAlias,&(cAlias+"->(DbStruct())")}
LOCAL aItens   := BD6->(DbStruct())
LOCAL aSubItens:= BD7->(DbStruct())
LOCAL nH       := 0
LOCAL nI	     := 0
LOCAL nJ	     := 0
LOCAL nL       := 0
LOCAL nM       := 0 
LOCAL nK	     := 0
LOCAL nCount   := 0 
LOCAL cNumero  := ""
LOCAL cCodOpe  := ""
LOCAL cCodLdp  := ""
LOCAL cCodPeg  := ""
LOCAL cSemGuia := ""
LOCAL cFiltAli := ""
LOCAL aDadosGuia := {}
LOCAL aLocClo  := {}
LOCAL nPosMatQrq:=0
LOCAL nFieldSeq :=BD7->(FieldPos("BD7_SEQ500"))
LOCAL nFielCodU :=BD7->(FieldPos("BD7_CODUNM"))
LOCAL lPodeImp   :=.F.
LOCAL cOpeClo	 := ""
LOCAL cLocClo 	:= ""
LOCAL cPegClo 	:= ""
LOCAL cTipGui  	:= ""
LOCAL lGuiaTotGlo:=.T.
LOCAL cFase:=""
LOCAL lTdItenGlo:=.T.
LOCAL lBloPFTOT  := GetNewPar("MV_PLSGCGP","0") == "1"
LOCAL lConsolida := GetNewPar("MV_PL550CO","0") == "1"
LOCAL nPosBLOCPA := 0
LOCAL nPosNUMTIT := 0
LOCAL nPosVLRTPF := 0
LOCAL nPosVLRPAG := 0
LOCAL lCriticou  := .F.
LOCAL lClonaBd6  := .F.
LOCAL lReturn    := .F.
Local nPRDA		:= aScan(aItens, {|x| x[1] == "BD6_CODRDA"})
Local nPLocal	:= aScan(aItens, {|x| x[1] == "BD6_CODLDP"})
Local nPPEG		:= aScan(aItens, {|x| x[1] == "BD6_CODPEG"})
Local nPnumero	:= aScan(aItens, {|x| x[1] == "BD6_NUMERO"})
Local dDtCtBf 	:= stod("")
DEFAULT aFields  := nil
DEFAULT lMsg     := .T.
DEFAULT cArqPar  := ""

//��������������������������������������������������������������������������Ŀ
//� O conteudo do parametro tem q estar na BW								 �
//����������������������������������������������������������������������������
SX5->(DbSetOrder(1))
If !SX5->(MsSeek(xFilial("SX5")+"BW"+alltrim(GetNewPar("MV_PLGUIES","123"))))
	If lMsg
		Help("",1,"PLSA500026")
	Endif
	Return
Endif
//��������������������������������������������������������������������������Ŀ
//� So posso clonar se a guia estiver pronta/faturada, desbloqueada			 �
//����������������������������������������������������������������������������
If ! &(cAlias+"->"+cAlias+"_FASE") $ "3,4" .Or. &(cAlias+"->"+cAlias+"_SITUAC") <> "1" //.or. !Empty(&(cAlias+"->"+cAlias+"_GUESTO"))
	If lMsg
		Help("",1,"PLSA500014")
	Endif
	Return
Else

	//��������������������������������������������������������������������������Ŀ
	//� Nesse momento verifica como sera importada a guia						 �
	//� MV_PAR03 = 1 Ativa/Pronta                 							     �
	//� MV_PAR03 = 2 Ativa/Faturada                                              �
	//� MV_PAR03 = 3 Ativa/Digita												 �
	//����������������������������������������������������������������������������

	If MV_PAR03=1
		cFase:="3"
	ElseIf MV_PAR03=2
	    cFase:="4"
    Else
	    cFase:="1"
    Endif

	//��������������������������������������������������������������������������Ŀ
	//� Pede confirmacao...                                                      �
	//����������������������������������������������������������������������������

	cOpeClo := &(cAlias+"->("+cAlias+"_CODOPE)")                          	
	cLocClo := &(cAlias+"->("+cAlias+"_CODLDP)")
	cPegClo := &(cAlias+"->("+cAlias+"_CODPEG)")
	cTipGui := &(cAlias+"->("+cAlias+"_TIPGUI)")


	aLocClo := {.T.,cOpeClo,cLocClo,cPegClo}

	//��������������������������������������������������������������������������Ŀ
	//� A guia a ser estornada agora esta toda dentro deste array				 �
	//����������������������������������������������������������������������������
	aGuiaOri := PlGetDadGui(cChaveGui,aCabec,aItens,aSubItens,cAlias)

	//���������������������������������������������������������������������������������Ŀ
	//� Antes de realizar qualquer processo verifico a integridade do array aGuiaOri		�
	//�����������������������������������������������������������������������������������
	For nI := 1 to Len(aGuiaOri[2])
		If ( ValType(aGuiaOri[2][nI][2]) != "A" .OR. Len(aGuiaOri[2][nI][2]) <= 0 )
			cErros += "Local: " + aGuiaOri[2][nI][1][nPLocal] + CRLF
			cErros += "Rda: " + aGuiaOri[2][nI][1][nPRDA] + CRLF
			cErros += "PEG: " + aGuiaOri[2][nI][1][nPPEG] + CRLF
			cErros += "N�mero: " + aGuiaOri[2][nI][1][nPnumero] + CRLF + CRLF
			lCriticou := .T.
		EndIf
	Next

	If lCriticou == .T.
		Return .F.
	EndIf

	//��������������������������������������������������������������������������Ŀ
	//� Vou varrer cada evento da guia se h� glosa para ver se vai clonar		 �
	//����������������������������������������������������������������������������
	For nI := 1 to Len(aGuiaOri[2])
		For nL := 1 to Len(aGuiaOri[2][nI][2])
	  		If Len(aGuiaOri[2][nI][2])>0 .And. (nPosSeq:=Ascan( aMatArq,{|x| Alltrim(x[20]) == Alltrim(aGuiaOri[2][nI][2][nL][BD7->(Fieldpos("BD7_SEQ500"))])} )) > 0
		  		If  alltrim(aMatArq[nPosSeq,12])== Alltrim(aGuiaOri[2][nI][2][nL][BD7->(Fieldpos("BD7_CODPRO"))])
					nPosMatQrq := Ascan( aMatArq,{|x| Alltrim(x[12]) == Alltrim(aGuiaOri[2][nI][2][nL][BD7->(Fieldpos("BD7_CODPRO"))]) .and. Alltrim(x[20]) == Alltrim(aGuiaOri[2][nI][2][nL][BD7->(Fieldpos("BD7_SEQ500"))])} )
					If nPosMatQrq > 0
						If Alltrim(aMatArq[nPosMatQrq][37])=="S" .AND. Alltrim(aMatArq[nPosMatQrq][17]) $ "01|02|13|14" //SOMENTES OS QUE FORAM GLOSADOS
							lPodeImp:=.t. // existe glosa para essa guia
						Else
							lTdItenGlo:=.F. // CASO SEJA .F. TENHA ITENS QUE NAO FORAM GLOSADOS PORTANTO NAO POSSO BLOQUEAR A GUIA ORIGINAL TODA TODA
						Endif
					Else
						Msgstop(STR0053+aGuiaOri[2][nI][2][nL][BD7->(Fieldpos("BD7_SEQ500"))]+STR0054,STR0051)
						Return(.F.)
					Endif
				Else
			
			   		cErros += "Local: " + aGuiaOri[2][nI][1][nPLocal] + CRLF
					cErros += "Rda: " + aGuiaOri[2][nI][1][nPRDA] + CRLF
					cErros += "PEG: " + aGuiaOri[2][nI][1][nPPEG] + CRLF
					cErros += "N�mero: " + aGuiaOri[2][nI][1][nPnumero] + CRLF 
					cErros += "Procedimento: " + Alltrim(aGuiaOri[2][nI][2][1][BD7->(Fieldpos("BD7_CODPRO"))]) +CRLF
					cErros += "Divergente do informando no arquivo. Sequencia :" +Alltrim(aGuiaOri[2][nI][2][nL][BD7->(Fieldpos("BD7_SEQ500"))]) +CRLF+CRLF
				
				Endif
			Endif
		Next 	
	Next	

	If !lPodeImp
		Return(.F.)
	Endif

	Begin Transaction

	If BD6->(MsSeek(xFilial("BD6")+cChaveGui))
		While !BD6->(Eof()) .and. BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV) == 	 xFilial("BD6")+cChaveGui

			BD6->(Reclock("BD6",.F.))
			BD6->BD6_TPESTO := '1'//nenhum
			BD6->BD6_CONCOB := '1'//sim
			BD6->BD6_CONPAG := '1'//sim
			BD6->BD6_CONMUS := '1'//sim
			BD6->BD6_CONMRD := '1'//sim
			BD6->(MsUnlock())

			BD7->(DbSetOrder(1))
			If BD7->(MsSeek(xFilial("BD7")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)))
				While ! BD7->(Eof()) .And. BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN) == ;
					xFilial("BD6")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)

					BD7->(Reclock("BD7",.F.))
					BD7->BD7_TPESTO := '1'//nenhum
					BD7->BD7_CONCOB := '1'//sim
					BD7->BD7_CONPAG := '1'//sim
					BD7->BD7_CONMUS := '1'//sim
					BD7->BD7_CONMRD := '1'//sim
					BD7->(MsUnlock())
					// Se foi contabilizado gravo uma nova data, se n�o foi coloco a mesma da guia origem.
					if empty(BD7->BD7_LA)
						dDtCtBf := BD7->BD7_DTDIGI 
					endif

					BD7->(DbSkip())
				Enddo
			Endif
			BD6->(DbSkip())
		Enddo
	Endif

	cCodOpe  := &(cAlias+"->"+cAlias+"_CODOPE")
	cCodLdp  := &(cAlias+"->"+cAlias+"_CODLDP")
	cCodPeg  := &(cAlias+"->"+cAlias+"_CODPEG")
	cSemGuia := cCodOpe+cCodLdp+cCodPeg
	nH       := PLSAbreSem(cSemGuia+".SMF")

	BCI->(DbSetOrder(1))
	BCI->(MsSeek(xFilial("BCI")+&(cAlias+"->"+cAlias+"_CODOPE")+&(cAlias+"->"+cAlias+"_CODLDP")+&(cAlias+"->"+cAlias+"_CODPEG")))

	//Busco o proximo numero da guia
	cFiltAli := &(cAlias+"->(TcSqlFilter())")
	
	&(cAlias+"->(DbClearFilter())")

	cNumero  := PLSA500NUM(cAlias,BCI->BCI_CODOPE, BCI->BCI_CODLDP, BCI->BCI_CODPEG)

	AaDd(aResumo,{&(cAlias+"->"+cAlias+"_CODPEG"),&(cAlias+"->"+cAlias+"_NUMERO"),cNumero,&(cAlias+"->"+cAlias+"_CODLDP"),"IMPORTADA"})

	DbSelectArea(aCabec[1])
	Reclock(aCabec[1],.F.)
	&(aCabec[1]+"_GUESTO") := aLocClo[2]+aLocClo[3]+aLocClo[4]+cNumero+&(cAlias+"->"+cAlias+"_ORIMOV")
	&(aCabec[1]+"_ESTORI") := '1'
	MsUnlock()
	/*��������������������������������������������������������������������������Ŀ
	//� Removido, pois ele excluia guias que acabaram de ser clonadas			 �
	//����������������������������������������������������������������������������
  	If nOpcaImp == 5 .AND. MV_PAR04 = 1 //importando o tipo 5 executora
  		Pl550Excluir(2,.F.) //exclui as guias clonadas para ficar somente a do tipo 5
	Endif */ 

	Reclock(aCabec[1],.T.)
	//��������������������������������������������������������������������������Ŀ
	//� Gravo o cabecalho da guia												 �
	//����������������������������������������������������������������������������
	For nI := 1 to Len(aGuiaOri[2])
		If Len(aGuiaOri[2][nI][2])>0
			For nL := 1 to Len(aGuiaOri[2][nI][2])	
				If  Ascan( aMatArq,{|x| Alltrim(x[12]) == Alltrim(aGuiaOri[2][nI][2][nL][BD7->(Fieldpos("BD7_CODPRO"))]) .and. Alltrim(x[20]) == Alltrim(aGuiaOri[2][nI][2][nL][BD7->(Fieldpos("BD7_SEQ500"))])} ) > 0
					nPosMatQrq := Ascan( aMatArq,{|x| Alltrim(x[12]) == Alltrim(aGuiaOri[2][nI][2][nL][BD7->(Fieldpos("BD7_CODPRO"))]) .and. Alltrim(x[20]) == Alltrim(aGuiaOri[2][nI][2][nL][BD7->(Fieldpos("BD7_SEQ500"))])} )
					If nPosMatQrq > 0
						If Alltrim(aMatArq[nPosMatQrq][37]) == "S" .AND. Alltrim(aMatArq[nPosMatQrq][17]) $ "01|02|13|14"

							For nCount := 1 to Len(aCabec[2])
								cCampo  := aCabec[2][nCount][1]
								cAliCp  := subs(cCampo,1,3)
			
								If cAliCp+"_CODOPE" == alltrim(cCampo)
									&cCampo := aLocClo[2]
								ElseIf cAliCp+"_CODLDP" == alltrim(cCampo)
									&cCampo := aLocClo[3]
								ElseIf cAliCp+"_CODPEG" == alltrim(cCampo)
									&cCampo := aLocClo[4]
								ElseIf cAliCp+"_NUMERO" == alltrim(cCampo)
									&cCampo := cNumero
								ElseIf cAliCp+"_FASE" == alltrim(cCampo)
									&cCampo := cFase
								ElseIf cAliCp+"_GUESTO" == alltrim(cCampo)
									&cCampo := cChaveGui
								ElseIf cAliCp+"_ESTORI" == alltrim(cCampo)
									&cCampo := '0'
								ElseIf cAliCp+"_GUIORI" == alltrim(cCampo)
									&cCampo := cChaveGui
								ElseIf Des550Field(cAliCp,cCampo)
									loop
								Else
									&cCampo := aGuiaOri[1][nCount]
								Endif
							Next
						EndIf
					EndIf
				EndIf
			Next
		EndIf
	Next	
	MsUnlock()

	//��������������������������������������������������������������������������Ŀ
	//� Vou varrer cada evento da guia											 �
	//����������������������������������������������������������������������������
	For nI := 1 to Len(aGuiaOri[2])
		lClonaBd6 := .F.
		For nL := 1 to Len(aGuiaOri[2][nI][2])
			If  Len(aGuiaOri[2][nI][2])>0 .And. Ascan( aMatArq,{|x| Alltrim(x[12]) == Alltrim(aGuiaOri[2][nI][2][nL][BD7->(Fieldpos("BD7_CODPRO"))]) .and. Alltrim(x[20]) == Alltrim(aGuiaOri[2][nI][2][nL][BD7->(Fieldpos("BD7_SEQ500"))])} ) > 0
				nPosMatQrq := Ascan( aMatArq,{|x| Alltrim(x[12]) == Alltrim(aGuiaOri[2][nI][2][nL][BD7->(Fieldpos("BD7_CODPRO"))]) .and. Alltrim(x[20]) == Alltrim(aGuiaOri[2][nI][2][nL][BD7->(Fieldpos("BD7_SEQ500"))])} )
				If nPosMatQrq > 0
					If aGuiaOri[2][nI][1][BD6->(Fieldpos("BD6_VLRGLO"))] > 0 .or. alltrim(STR(nOpcaImp)) $ '3|4|5|6|7|8' .or. MV_PAR04=1   // importa��a tipo 5 e 6 nao tem glosa /MV_PAR04=1 � o retorno do a550 tipo 1 da origem...  
						//��������������������������������������������������������������������������Ŀ
						//� Alltrim(aMatArq[nPosMatQrq][37])=="S" --> SOMENTES OS QUE FORAM GLOSADOS �
						//�																			 �
						//�	Alltrim(aMatArq[nPosMatQrq][17]) $ "01|02|13|14" 						 �              
						//�	So posso clonar quando o Reg R552-Seq 017 - TP_ACORDO for 01,02,13 e 14  �
						//����������������������������������������������������������������������������
						If Alltrim(aMatArq[nPosMatQrq][37]) == "S" .AND. Alltrim(aMatArq[nPosMatQrq][17]) $ "01|02|13|14"
							lClonaBd6 := .T.
							exit
						Endif
					Endif
				Else
					lReturn := .T.
					Msgstop(STR0053+aGuiaOri[2][nI][2][nL][BD7->(Fieldpos("BD7_SEQ500"))]+STR0054,STR0051)
					DisarmTransaction()
					Break
				Endif
			Endif
		Next
		
		If lClonaBd6
			nPosBLOCPA := Ascan(aItens,{|x|x[1] == "BD6_BLOCPA"})
			nPosNUMTIT := Ascan(aItens,{|x|x[1] == "BD6_NUMTIT"})
			nPosVLRTPF := Ascan(aItens,{|x|x[1] == "BD6_VLRTPF"})
			nPosVLRPAG := Ascan(aItens,{|x|x[1] == "BD6_VLRPAG"})
			//��������������������������������������������������������������������������Ŀ
			//� Gravo o cabecalho do evento												 �
			//����������������������������������������������������������������������������
			DbSelectArea("BD6")
			Reclock("BD6",.T.)
			For nK := 1 to Len(aItens)
				cCampo  := aItens[nK][1]
				cAliCp  := subs(cCampo,1,3)
				If cAliCp+"_CODOPE" == alltrim(cCampo)
					&cCampo := aLocClo[2]
				ElseIf cAliCp+"_CODLDP" == alltrim(cCampo)
					&cCampo := aLocClo[3]
				ElseIf cAliCp+"_CODPEG" == alltrim(cCampo)
					&cCampo := aLocClo[4]
				ElseIf cAliCp+"_NUMERO" == alltrim(cCampo)
					&cCampo := cNumero
				ElseIf cAliCp+"_FASE" == alltrim(cCampo)
					&cCampo := cFase
				ElseIf cAliCp+"_TPESTO" == alltrim(cCampo)
					&cCampo := "1"
				ElseIf cAliCp+"_GUESTO" == alltrim(cCampo)
					&cCampo := cChaveGui
				ElseIf cAliCp+"_CONCOB" == alltrim(cCampo)
					&cCampo := '1'
				ElseIf cAliCp+"_CONPAG" == alltrim(cCampo)
					&cCampo := '0'
				ElseIf cAliCp+"_CONMUS" == alltrim(cCampo)
					&cCampo := '0'
				ElseIf cAliCp+"_CONMRD" == alltrim(cCampo)
					&cCampo := '0'
				ElseIf cAliCp+"_QTDAPR" == alltrim(cCampo)
					&cCampo := aMatArq[nPosMatQrq,18]
				ElseIf cAliCp+"_QTDPRO" == alltrim(cCampo)
					&cCampo := aMatArq[nPosMatQrq,36]
				ElseIf cAliCp+"_BLOPAG" == alltrim(cCampo)
					&cCampo := "0"
				ElseIf cAliCp+"_MOTBPG" == alltrim(cCampo)
					&cCampo := ""
				ElseIf cAliCp+"_DESBPG" == alltrim(cCampo)
					&cCampo := ""
				ElseIf cAliCp+"_SITUAC" == alltrim(cCampo)
					&cCampo := "1"
				ElseIf cAliCp+"_GUIORI" == alltrim(cCampo)
					&cCampo := cChaveGui
				//��������������������������������������������������������������������������Ŀ
				//� BLOCPA tem tratamento diferenciado para definir coparticipacao			 �
		   		//����������������������������������������������������������������������������
				ElseIf cAliCp+"_BLOCPA" == alltrim(cCampo)
				
					If lConsolida .And. !MV_PAR04 == 1
						//������������������������������������������������������������������������������Ŀ
						//� Guia foi glosada integralmente (BLOCPA = SIM com MV_PLSGCGP ativado), mas na �
						//� nova negociacao tem valor de pagamento.                                      �
						//� Guia Original | BLOCPA - SIM   	 										     �
						//� Guia Clonada  | BLOCPA - NAO  												 �
						//��������������������������������������������������������������������������������
						If (aGuiaOri[2][nI][1][nPosBLOCPA] == "1") .And. lBloPFTOT .And. (aGuiaOri[2][nI][1][nPosVLRPAG] == 0)
							&cCampo := "0"
					   		nVLRTPF := aGuiaOri[2][nI][1][nPosVLRTPF]
						//������������������������������������������������������������������������������Ŀ
			   			//� Guia original com o BLOCPA 'NAO' e NUMTIT Vazio. Esta apta a cobranca,       �
			   			//� Devemos bloquear a original e cobrar a guia clonada.   					     �
		  				//� Guia Original | BLOCPA - SIM   	 										     �
	 					//� Guia Clonada  | BLOCPA - NAO  												 �
		   				//��������������������������������������������������������������������������������
		  				ElseIf (aGuiaOri[2][nI][1][nPosBLOCPA] <> "1") .And. Empty(aGuiaOri[2][nI][1][nPosNUMTIT])
			   				&cCampo := "0"
							nVLRTPF := aGuiaOri[2][nI][1][nPosVLRTPF]
			 			//������������������������������������������������������������������������������Ŀ
			 			//� Guia original com o BLOCPA 'NAO' e NUMTIT Preenchido. Guia original ja foi   �
			 			//� cobrada. Guia original contina como apta a cobranca e bloqueamos o clone     �
						//� Guia Original | BLOCPA - NAO   	 										     �
			 			//� Guia Clonada  | BLOCPA - SIM  												 �
			 			//��������������������������������������������������������������������������������
						ElseIf (aGuiaOri[2][nI][1][nPosBLOCPA] <> "1") .And. !Empty(aGuiaOri[2][nI][1][nPosNUMTIT])
			 				&cCampo := "1"
			 			Else
			 			 	&cCampo := "0"
			 			EndIf
                    //��������������������������������������������������������������������������Ŀ
					//� Guia Executora mantenho os mesmos valores                     			 �
			   		//����������������������������������������������������������������������������    
					ElseIf MV_PAR04 == 1//Unimed Origem
						&cCampo := aGuiaOri[2][nI][1][nK]
		            Else
		            	&cCampo := "0"
		            EndIf
				//��������������������������������������������������������������������������Ŀ
				//� VLRTPF tem tratamento diferenciado para definir coparticipacao			 �
		   		//����������������������������������������������������������������������������
			   	ElseIf cAliCp+"_VLRTPF" == alltrim(cCampo)
			   	
			   		If lConsolida .And. !MV_PAR04 == 1
						//������������������������������������������������������������������������������Ŀ
						//� Guia foi glosada integralmente (BLOCPA = SIM com MV_PLSGCGP ativado), mas na �
						//� nova negociacao tem valor de pagamento.                                      �
						//� - Copia valor de pagamento     	 										     �
						//��������������������������������������������������������������������������������
						If (aGuiaOri[2][nI][1][nPosBLOCPA] == "1") .And. lBloPFTOT  .And. (aGuiaOri[2][nI][1][nPosVLRPAG] == 0)
					   		&cCampo := aGuiaOri[2][nI][1][nPosVLRTPF]
						//������������������������������������������������������������������������������Ŀ
			   			//� Guia original com o BLOCPA 'NAO' e NUMTIT Vazio. Esta apta a cobranca,       �
			   			//� Devemos bloquear a original e cobrar a guia clonada.   					     �
		  				//� - Copia valor de pagamento   	 										     �
	 					//��������������������������������������������������������������������������������
		  				ElseIf (aGuiaOri[2][nI][1][nPosBLOCPA] <> "1") .And. Empty(aGuiaOri[2][nI][1][nPosNUMTIT])
			   				&cCampo := aGuiaOri[2][nI][1][nPosVLRTPF]
			 			//������������������������������������������������������������������������������Ŀ
			 			//� Guia original com o BLOCPA 'NAO' e NUMTIT Preenchido. Guia original ja foi   �
			 			//� cobrada. Guia original contina como apta a cobranca e bloqueamos o clone     �
						//� - Nao copia valor de pagamento      									     �
			 			//��������������������������������������������������������������������������������
						ElseIf (aGuiaOri[2][nI][1][nPosBLOCPA] <> "1") .And. !Empty(aGuiaOri[2][nI][1][nPosNUMTIT])
			 				&cCampo := 0
	                    Else
	                    	&cCampo := 0
	                    EndIf
                	//��������������������������������������������������������������������������Ŀ
					//� Guia Executora mantenho os mesmos valores                     			 �
			   		//����������������������������������������������������������������������������    
					ElseIf MV_PAR04 == 1//Unimed Origem
						&cCampo := aGuiaOri[2][nI][1][nK]
					Else
						&cCampo := 0
					EndIf

				ElseIf Des550Field(cAliCp,cCampo)
					loop
				Else
					&cCampo := aGuiaOri[2][nI][1][nK]
				Endif
			Next
			MsUnlock()
			//��������������������������������������������������������������������������Ŀ
			//� Vou gravar cada unidade deste evento									 �
			//����������������������������������������������������������������������������
			For nJ := 1 to Len(aGuiaOri[2][nI][2])

				nPosBD7 := Ascan( aMatArq,{|x| x[20] == Alltrim(aGuiaOri[2][nI][2][nJ][nFieldSeq]) } )

				DbSelectArea("BD7")
				Reclock("BD7",.T.)
				
				For nK := 1 to Len(aSubItens)
				
					cCampo  := aSubItens[nK][1]
					cAliCp  := subs(cCampo,1,3)
				
					If cAliCp+"_CODOPE" == alltrim(cCampo)
						&cCampo := aLocClo[2]
					ElseIf cAliCp+"_CODLDP" == alltrim(cCampo)
						&cCampo := aLocClo[3]
					ElseIf cAliCp+"_CODPEG" == alltrim(cCampo)
						&cCampo := aLocClo[4]
					ElseIf cAliCp+"_NUMERO" == alltrim(cCampo)
						&cCampo := cNumero
					ElseIf cAliCp+"_FASE" == alltrim(cCampo)
						&cCampo := cFase
					ElseIf cAliCp+"_GUESTO" == alltrim(cCampo)
						&cCampo := cChaveGui
					ElseIf cAliCp+"_TPESTO" == alltrim(cCampo)
						&cCampo := "1"
					ElseIf cAliCp+"_CONCOB" == alltrim(cCampo)
						&cCampo := '0'
					ElseIf cAliCp+"_CONPAG" == alltrim(cCampo)
						&cCampo := '0'
					ElseIf cAliCp+"_CONMUS" == alltrim(cCampo)
						&cCampo := '0'
					ElseIf cAliCp+"_CONMRD" == alltrim(cCampo)
						&cCampo := '0'
					ElseIf cAliCp+"_BLOPAG" == alltrim(cCampo)
						&cCampo := '0'
					ElseIf cAliCp+"_SITUAC" == alltrim(cCampo)
						&cCampo := '1'
					ElseIf cAliCp+"_DTCTBF" == alltrim(cCampo)
						if empty(dDtCtBf)						
							&cCampo := date()
						else
							&cCampo := dDtCtBf
						endif
					ElseIf cAliCp+"_VLRGLO" == alltrim(cCampo) .And. nPosBD7 > 0
                   		//��������������������������������������������������������������������������Ŀ
						//� Unimed Origem        								                	 �
						//����������������������������������������������������������������������������
                        If MV_PAR04 == 2//Unimed Origem
							If aGuiaOri[2][nI][2][nJ][nFielCodU] =="FIL"
							    &cCampo := aMatArq[nPosBD7,26]
							ElseIf aGuiaOri[2][nI][2][nJ][nFielCodU] $ "COP|COR"
								&cCampo := aMatArq[nPosBD7,23]
							Else
								&cCampo := aMatArq[nPosBD7,15]
							Endif
                  		//��������������������������������������������������������������������������Ŀ
						//� Unimed Executora                     									 �
						//����������������������������������������������������������������������������
                        Else
                        	If aGuiaOri[2][nI][2][nJ][nFielCodU] =="FIL"
							    &cCampo := (aMatArq[nPosBD7,24] - aMatArq[nPosBD7,25])
							ElseIf aGuiaOri[2][nI][2][nJ][nFielCodU] $ "COP|COR"
								&cCampo := (aMatArq[nPosBD7,21] - aMatArq[nPosBD7,22])
							Else
								&cCampo := (aMatArq[nPosBD7,13] - aMatArq[nPosBD7,14])
							Endif
							//��������������������������������������������������������������������������Ŀ
							//� Vou somar os valores acordados        									 �
							//����������������������������������������������������������������������������
							nVlrAcServ += aMatArq[nPosBD7,15] + aMatArq[nPosBD7,23] + aMatArq[nPosBD7,26]	

                       EndIf

					ElseIf cAliCp+"_VLRGTX" == alltrim(cCampo) .And. nPosBD7 > 0
                   		//��������������������������������������������������������������������������Ŀ
						//� Unimed Origem        								                	 �
						//����������������������������������������������������������������������������
                        If MV_PAR04 == 2//Unimed Origem
							If aGuiaOri[2][nI][2][nJ][nFielCodU] =="FIL"
							    &cCampo := aMatArq[nPosBD7,35]
							ElseIf aGuiaOri[2][nI][2][nJ][nFielCodU] $ "COP|COR"
								&cCampo := aMatArq[nPosBD7,32]
							Else
								&cCampo := aMatArq[nPosBD7,29]
							Endif
                  		//��������������������������������������������������������������������������Ŀ
						//� Unimed Executora                     									 �
						//����������������������������������������������������������������������������
                        Else
                        	If aGuiaOri[2][nI][2][nJ][nFielCodU] =="FIL"
							    &cCampo := (aMatArq[nPosBD7,33] - aMatArq[nPosBD7,34])
							ElseIf aGuiaOri[2][nI][2][nJ][nFielCodU] $ "COP|COR"
								&cCampo := (aMatArq[nPosBD7,30] - aMatArq[nPosBD7,31])
							Else
								&cCampo := (aMatArq[nPosBD7,27] - aMatArq[nPosBD7,28])
							Endif
							//��������������������������������������������������������������������������Ŀ
							//� Vou somar os valores acordados        									 �
							//����������������������������������������������������������������������������											
							nVlrAcTax  += aMatArq[nPosBD7,29] + aMatArq[nPosBD7,32] + aMatArq[nPosBD7,35]			

                       EndIf

					ElseIf cAliCp+"_VLRPAG" == alltrim(cCampo) .And. nPosBD7 > 0

						If aGuiaOri[2][nI][2][nJ][nFielCodU] =="FIL"
						    &cCampo := aMatArq[nPosBD7,25]+aMatArq[nPosBD7,34]
						ElseIf aGuiaOri[2][nI][2][nJ][nFielCodU] $ "COP|COR"
							&cCampo := aMatArq[nPosBD7,22]+aMatArq[nPosBD7,31]
						Else
							&cCampo := aMatArq[nPosBD7,14]+aMatArq[nPosBD7,28]
						Endif

					ElseIf cAliCp+"_VLTXPG" == alltrim(cCampo) .And. nPosBD7 > 0

						If aGuiaOri[2][nI][2][nJ][nFielCodU] == "FIL"
						    &cCampo := aMatArq[nPosBD7,34]
						ElseIf aGuiaOri[2][nI][2][nJ][nFielCodU] $ "COP|COR"
							&cCampo := aMatArq[nPosBD7,31]
						Else
							&cCampo := aMatArq[nPosBD7,28]
						Endif
					//��������������������������������������������������������������������������Ŀ
		   			//� VLRTPF tem tratamento diferenciado para definir coparticipacao			 �
	   				//����������������������������������������������������������������������������
				   	ElseIf cAliCp+"_VLRTPF" == alltrim(cCampo) .And. lConsolida
						//������������������������������������������������������������������������������Ŀ
						//� Guia foi glosada integralmente (BLOCPA = SIM), mas na nova negociacao        �
						//� tem valor de pagamento.                                                      �
						//� - Copia valor de pagamento     	 										     �
						//��������������������������������������������������������������������������������
						If (aGuiaOri[2][nI][1][nPosBLOCPA] == "1") // .And. (nVlrPag > 0) .And. (aGuiaOri[2][nI][1][nPosVLRPAG] == 0)
					   		&cCampo := aGuiaOri[2][nI][1][nPosVLRTPF]
						//������������������������������������������������������������������������������Ŀ
			   			//� Guia original com o BLOCPA 'NAO' e NUMTIT Vazio. Esta apta a cobranca,       �
			   			//� Devemos bloquear a original e cobrar a guia clonada.   					     �
		  				//� - Copia valor de pagamento   	 										     �
	 					//��������������������������������������������������������������������������������
		  				ElseIf (aGuiaOri[2][nI][1][nPosBLOCPA] <> "1") .And. Empty(aGuiaOri[2][nI][1][nPosNUMTIT])
			   				&cCampo := aGuiaOri[2][nI][1][nPosVLRTPF]
			 			//������������������������������������������������������������������������������Ŀ
			 			//� Guia original com o BLOCPA 'NAO' e NUMTIT Preenchido. Guia original ja foi   �
			 			//� cobrada. Guia original contina como apta a cobranca e bloqueamos o clone     �
						//� - Nao copia valor de pagamento      									     �
			 			//��������������������������������������������������������������������������������
						ElseIf (aGuiaOri[2][nI][1][nPosBLOCPA] <> "1") .And. !Empty(aGuiaOri[2][nI][1][nPosNUMTIT])
			 				&cCampo := 0
						EndIf

					ElseIf Des550Field(cAliCp,cCampo)
						loop


						/* referencia
						BD7->BD7_VLRAPR  13
						BD7->BD7_VLRPAG  14
						BD6->BD6_QTDAPR	 18 x
						BD7->BD7_VLRAPR  19
						BD7->BD7_VLRAPR	 21
						BD7->BD7_VLRPAG  22
						BD7->BD7_VLRAPR  25
						BD7->BD7_VLRPAG  26
						BD7->BD7_VTXPAP  28
						BD7->BD7_VLTXPG  29
						BD7->BD7_VTXPAP  31
						BD7->BD7_VLTXPG  32
						BD7->BD7_VLTXPG  35
						BD6->BD6_QTDPRO  37 x
						*/

					Else

						&cCampo := aGuiaOri[2][nI][2][nJ][nK]
					Endif
				Next
				MsUnlock()
			Next
			
			//Atualiza BD6_VLRPAG e BD6_VLRGLO    									 
			nVlrGlo := 0
			nVlrPag := 0
			BD7->(DbSetOrder(1))//BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN+BD7_CODUNM
			If BD7->(DbSeek(xFilial("BD7")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)))
			
				While xFilial("BD6")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN) == ;
					  xFilial("BD7")+BD7->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN) .And. !BD7->(Eof())
					
					nVlrGlo += BD7->BD7_VLRGLO
					nVlrPag += BD7->BD7_VLRPAG
					
				BD7->(DbSkip())
				EndDo
				
			EndIf
			
			DbSelectArea("BD6")
			
			Reclock("BD6",.F.)
			
			BD6->BD6_VLRGLO := nVlrGlo
			BD6->BD6_VLRPAG := nVlrPag
			
			//Atualiza BD6_VLRTPF, BD6_BLOCPA e BD7_VLRTPF se nao houver valor de pagamento
			If lBloPFTOT .And. lConsolida .And. nVlrPag == 0
				
				BD6->BD6_VLRTPF := 0
		  		BD6->BD6_BLOCPA := "1"
		  		
		  		If BD7->(DbSeek(xFilial("BD7")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)))
			
			 		While xFilial("BD6")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN) == ;
						  xFilial("BD7")+BD7->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN) .And. !BD7->(Eof())

					Reclock("BD7",.F.)
						BD7->BD7_VLRTPF := 0
					BD7->(MsUnlock())

					BD7->(DbSkip())
			   		EndDo
		  		EndIf
			EndIf
			BD6->(MsUnlock())	
		EndIf	
	Next	
	//��������������������������������������������������������������������������Ŀ
	//� Atualiza BD5_VLRPAG e BD5_VLRGLO    									 �
	//����������������������������������������������������������������������������
	nVlrGlo := 0
	nVlrPag := 0
	BD6->(DbSetOrder(1))//BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN+BD6_CODPAD+BD6_CODPRO
	If BD6->(DbSeek(xFilial("BD6")+BD5->(BD5_CODOPE+BD5_CODLDP+BD5_CODPEG+BD5_NUMERO+BD5_ORIMOV)))
		While xFilial("BD5")+BD5->(BD5_CODOPE+BD5_CODLDP+BD5_CODPEG+BD5_NUMERO+BD5_ORIMOV) ==  ;
		      xFilial("BD6")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV) .And. !BD6->(Eof())

   		      nVlrGlo += BD6->BD6_VLRGLO
			  nVlrPag += BD6->BD6_VLRPAG
			  BD6->(DbSkip())
		EndDo
	EndIf

	If cAlias="BD5"
		DbSelectArea("BD5")
		
		Reclock("BD5",.F.)
			BD5->BD5_VLRGLO := nVlrGlo
			BD5->BD5_VLRPAG := nVlrPag
		BD5->(MsUnlock())
	Else
		DbSelectArea("BE4")
		
		Reclock("BE4",.F.)
			BE4->BE4_VLRGLO := nVlrGlo
			BE4->BE4_VLRPAG := nVlrPag
		BE4->(MsUnlock())
	EndIf

	PLSFechaSem(nH,cSemGuia+".SMF")

	If cAlias="BD5"
		&(cAlias+"->(DbSeek('"+xFilial(cAlias)+cChaveGui+"'))")//depois da clonagem eu deixo posicionado na guia origem
	Else
		&(cAlias+"->(DbSeek('"+xFilial(cAlias)+cChaveBE4+"'))")//depois da clonagem eu deixo posicionado na guia origem
	Endif

	//��������������������������������������������������������������������������Ŀ
	//� Alterando a situacao da guia original                                    �
	//����������������������������������������������������������������������������

	If cAlias= "BD5"
	
		cChavePes  := BD5->(BD5_FILIAL+BD5_CODOPE+BD5_CODLDP+BD5_CODPEG+BD5_NUMERO+BD5_ORIMOV)

		If BD6->(DbSeek(cChavePes))
			While !BD6->(Eof()) .AND. BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV)=cChavePes
				
				//******** Importa��a do Tipo 1 ********** 
				// importacao do tipo 1
				If nOpcaImp = 1    

					//���������������������������������������������������������������Ŀ
					//�Bloqueando somente os itens que foram glosados na guia original�
					//�����������������������������������������������������������������

					If BD7->(DbSeek(xFilial("BD7")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)))
						
						While ! BD7->(Eof()) .And. BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN) == ;
													xFilial("BD7")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)

							nPosMatQrq := Ascan( aMatArq,{|x| Alltrim(x[12]) == Alltrim(BD7->BD7_CODPRO) .and. Alltrim(x[20]) == Alltrim(BD7->BD7_SEQ500)})
							
							If nPosMatQrq > 0
								If aMatArq[nPosMatQrq,37]=="S" .AND. Alltrim(aMatArq[nPosMatQrq][17]) $ "01|02|13|14"
									
									BD7->(RecLock("BD7",.F.))

										PLBLOPC("BD7", .t., cCodCritica, cDesCritica)

									BD7->(MsUnlock())
									
								Endif
								
							Endif
							
							BD7->(DbSkip())
						Enddo
						
					Endif
					
					BD6->(RecLock("BD6",.F.))
					
						PLBLOPC("BD6", .t., cCodCritica, cDesCritica, .t., .t., .t.)

					BD6->(MsUnlock())
				Endif

				//���������������������������������������������������������������Ŀ
				//�Importando Tipos de Arquivos 3,4,5,7 e 8					 �
				//�����������������������������������������������������������������
				If alltrim(STR(nOpcaImp)) $ '3|4|5|7|8'

					nPosRegOri := Ascan( aMatArq,{|x| Alltrim(x[12]) == Alltrim(BD6->BD6_CODPRO) })

					//���������������������������������������������������������������Ŀ
					//�Bloqueando somente os itens que foram glosados na guia original�
					//�����������������������������������������������������������������
						If nPosRegOri > 0 .And. BD6->BD6_VLRGLO > 0 .And. aMatArq[nPosRegOri,17] $ "01|02|13|14"

							If BD7->(DbSeek(xFilial("BD7")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)))
								While ! BD7->(Eof()) .And. BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN) == ;
									xFilial("BD7")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)
									BD7->(RecLock("BD7",.F.))

									nPosMatQrq:=Ascan( aMatArq,{|x| Alltrim(x[12]) == Alltrim(BD7->BD7_CODPRO) .and. Alltrim(x[20]) == Alltrim(BD7->BD7_SEQ500)})
									//���������������������������������������������������������������Ŀ
									//� lConsolida define se sistema realizara consolidacao do clone  �
				   					//�����������������������������������������������������������������
									If lConsolida
									
										PLBLOPC("BD7", .t., cCodCritica, cDesCritica)
										
									Else
										If nPosMatQrq > 0
											//���������������������������������������������������������������Ŀ
											//� Para Bloquear os itens somente clonados						  �
							   		   		//�����������������������������������������������������������������
									    	If Alltrim(aMatArq[nPosMatQrq][37]) == "S" .AND. Alltrim(aMatArq[nPosMatQrq][17]) $ "01|02|13|14"
												
												PLBLOPC("BD7", .t., cCodCritica, cDesCritica)
												
											Else
												PLBLOPC("BD7", .f.)
									   	  	EndIf
									   	  	
										EndIf
									EndIf
									BD7->(MsUnlock())
									BD7->(DbSkip())
								Enddo
							Endif
							BD6->(RecLock("BD6",.F.))
							//���������������������������������������������������������������Ŀ
							//� lConsolida define se sistema realizara consolidacao do clone  �
				   			//�����������������������������������������������������������������
							If lConsolida
							
								PLBLOPC("BD6", .t., cCodCritica, cDesCritica, .t., .f., .t. )
								
								//Se ja ha titulo gerado, nao altero o Status do BLOCPA
								If Empty(BD6->BD6_NUMTIT)

									PLBLOPC("BD6", .t., cCodCritica, cDesCritica, .f., .t.)
									
							   	EndIf
						    Else
						    	If nPosMatQrq > 0
									//���������������������������������������������������������������Ŀ
									//� Para Bloquear os itens somente clonados						  �
					   		   		//�����������������������������������������������������������������
							    	If Alltrim(aMatArq[nPosMatQrq][37]) == "S" .AND. Alltrim(aMatArq[nPosMatQrq][17]) $ "01|02"
							    		
							    		PLBLOPC("BD6", .t., cCodCritica, cDesCritica, .t., .t., .t. )
								   		
								   	EndIf
								   	
								 EndIf
								
						    EndIf
							BD6->(MsUnlock())
						Else
							lGuiaTotGlo:=.F.
						Endif
				Endif

				BD6->(DbSkip())
			Enddo
		Endif

	Else

		cChavePes  := BE4->(BE4_FILIAL+BE4_CODOPE+BE4_CODLDP+BE4_CODPEG+BE4_NUMERO+BE4_ORIMOV)

		If BD6->(DbSeek(cChavePes))
			While !BD6->(Eof()) .AND. BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV)=cChavePes

				//******** Importa��a do Tipo 1 ********** �
				If nOpcaImp = 1    // importacao do tipo 1
					
					//Bloqueando somente os itens que foram glosados na guia original
					If BD6->BD6_VLRGLO > 0
					
						If BD7->(DbSeek(xFilial("BD7")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)))
					
							While ! BD7->(Eof()) .And. BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN) == ;
														xFilial("BD7")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)
								
								nPosMatQrq := Ascan( aMatArq,{|x| x[12] == BD7->BD7_CODPRO .and. x[20] == BD7->BD7_SEQ500})

								If nPosMatQrq > 0
								
									If aMatArq[nPosMatQrq,37] == "S" .AND. Alltrim(aMatArq[nPosMatQrq][17]) $ "01|02|13|14"
										
										BD7->(RecLock("BD7",.F.))
										
											PLBLOPC("BD7", .t., cCodCritica, cDesCritica)
											
										BD7->(MsUnlock())
										
									EndIf
									
								Endif
								
							BD7->(DbSkip())
							Enddo
							
						Endif
						
						BD6->(RecLock("BD6",.F.))
						
							PLBLOPC("BD6", .t., cCodCritica, cDesCritica, .t., .t., .t. )
						
						BD6->(MsUnlock())
						
					Else
						lGuiaTotGlo:=.F.
					Endif
				Endif

				//���������������������������������������������������������������Ŀ
				//�Importando Tipos de Arquivos 3,4,5,7 e 8						  �
				//�����������������������������������������������������������������
				If alltrim(STR(nOpcaImp)) $ '3|4|5|7|8'
					//���������������������������������������������������������������Ŀ
					//�Bloqueando somente os itens que foram glosados na guia original�
					//�����������������������������������������������������������������
					If BD6->BD6_VLRGLO > 0
					
						If BD7->(DbSeek(xFilial("BD7")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)))
					
							While ! BD7->(Eof()) .And. BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN) == ;
														xFilial("BD7")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)
								
								BD7->(RecLock("BD7",.F.))

								nPosMatQrq := Ascan( aMatArq,{|x| Alltrim(x[12]) == Alltrim(BD7->BD7_CODPRO) .and. Alltrim(x[20]) == Alltrim(BD7->BD7_SEQ500)})
								
								//lConsolida define se sistema realizara consolidacao do clone 
								If lConsolida
								
									If Empty(BD6->BD6_NUMTIT)
										
										PLBLOPC("BD7", .t., cCodCritica, cDesCritica)
										
									EndIf
									
								Else
								
									If nPosMatQrq > 0
									
										//Para Bloquear os itens somente clonados						  
									    If Alltrim(aMatArq[nPosMatQrq][37]) == "S" .AND. Alltrim(aMatArq[nPosMatQrq][17]) $ "01|02|13|14"
											PLBLOPC("BD7", .t., cCodCritica, cDesCritica)
										Else
											PLBLOPC("BD7", .f.)
									   	EndIf
									   	
									EndIf
									
								EndIf
								
								BD7->(MsUnlock())
								BD7->(DbSkip())
							Enddo
							
						Endif
						
						BD6->(RecLock("BD6",.F.))
						//���������������������������������������������������������������Ŀ
						//� lConsolida define se sistema realizara consolidacao do clone  �
	   					//�����������������������������������������������������������������
						If lConsolida
							
							PLBLOPC("BD6", .t., cCodCritica, cDesCritica, .t., .f., .t. )
							
							//Se ja ha titulo gerado, nao altero o Status do BLOCPA
							If Empty(BD6->BD6_NUMTIT)
								
								PLBLOPC("BD6", .t., cCodCritica, cDesCritica, .f., .t.)
								
								
							EndIf
					    Else
						    If nPosMatQrq > 0
								//���������������������������������������������������������������Ŀ
								//� Para Bloquear os itens somente clonados						  �
					   			//�����������������������������������������������������������������
							   	If Alltrim(aMatArq[nPosMatQrq][37]) == "S" .AND. Alltrim(aMatArq[nPosMatQrq][17]) $ "01|02|13|14"
							   		
							   		PLBLOPC("BD6", .t., cCodCritica, cDesCritica, .t., .t., .t. )
							   		
							   	EndIf
							   	
							EndIf
							
					    EndIf
						BD6->(MsUnlock())
					Else
						lGuiaTotGlo:=.F.
					Endif
				Endif

				//���������������������������������������������������������������Ŀ
				//�Importando Tipo 1- Inclusao Question para Unimed 2-Origem 	  �
				//� MV_PAR04= 1-Executora ou 2-Origem  						 	  �
				//�����������������������������������������������������������������
				If(nOpcaImp == 1 .And. MV_PAR04 ==2)

					If BD7->(DbSeek(xFilial("BD7")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)))
						
						While ! BD7->(Eof()) .And. BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN) == ;
													xFilial("BD7")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)
							
							PLBLOPC("BD7", .t., cCodCritica, cDesCritica)
																				
						BD7->(DbSkip())
						Enddo
						
					Endif
					
					BD6->(RecLock("BD6",.F.))
						
						PLBLOPC("BD6", .t., cCodCritica, cDesCritica, .t., .t., .t. )
			
					BD6->(MsUnlock())
				Endif

				BD6->(DbSkip())
			Enddo
		Endif
	Endif
	
	//Unimed Origem - Retornado pelo BRJ		 
	If MV_PAR04 == 2 // 2-Origem
		BRJ->(RecLock("BRJ",.F.))
			BRJ->BRJ_NIV550 := cTpArq
		
		//Campos de faturamento parcial 1 e 2 - Versao 7.0
		If Alltrim(mv_par01) >= "A550G" .And. Alltrim(STR(nOpcaImp)) $ "34" .And. BRJ->(FieldPos("BRJ_ARQPAR")) > 0 
			BRJ->BRJ_ARQPAR := cArqPar
		EndIf                                 
		
		BRJ->(MsUnLock())
	Endif


	End Transaction

	If !lReturn
	If !Empty(cFiltAli)
		DbSelectArea(cAlias)
		DbSetFilter({||&cFiltAli},cFiltAli)
	Endif
	EndIf
Endif


Return(!lReturn)



/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �Des550Field� Autor � Daher		        | Data � 08.12.05 ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Dado um campo, retorno se ele deve ser desconsiderado		  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
STATIC Function Des550Field(cAliCp,cCampo)
LOCAL lRet    := .F.
LOCAL aFields := {"_DTGRCP","_INTFAT","_STAFAT","_NUMFAT","_OPEFAT","_NUMSE1",;
                  "_SEQPF","_PERCEN","_VLRTPF","_VLRPAG","_LAPRO","_DTPRO","_CHVPRO",;
                  "_LA","_DTLA","_CHVLA","_PERPF"}
LOCAL nI	  := 0

For nI:= 1 to Len(aFields)
	If cAliCp+aFields[nI] == alltrim(cCampo)
		lRet := .T.
		exit
	Endif
Next

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PL550ImpOr�Autor  �Microsiga           � Data �  03/16/12   ���
�������������������������������������������������������������������������͹��
���Desc.     �UNIMED ORIGEM - Importa os Tipos de Arquivos 3,4,5,7 e 8    ���
��� 		 �															  ���
���          �Entrara na funcao quando o MV_PAR04 = 2 (Unimed Origem)	  ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function PL550ImpOr()

LOCAL cPLSFiltro  := ""

//�������������������������������������������������������������������������������Ŀ
//� cGerPtu = "0" Titulo de Contestacao foi criado no Lote de Pagto(PLSA470)      �
//� cGerPtu = "1" Titulo de Contestacao sera criado no momento da geracao do A560 �
//���������������������������������������������������������������������������������
cPLSFiltro := "@BRJ_FILIAL = '"+xFilial("BRJ")+"' AND BRJ_REGPRI = '1' "
cPLSFiltro += " AND (((BRJ_NUMSE2 <> ' ' AND BRJ_PRESE2 <> ' ' AND BRJ_TIPSE2 <> ' ') OR (BRJ_TPCOB = '1' AND BRJ_PREE2N <> ' ' AND BRJ_NUME2N <> ' ') AND BRJ_GERPTU = '0')"
cPLSFiltro += " OR ((BRJ_PREFIX <> ' ' AND BRJ_NUMTIT <> ' ') OR (BRJ_TPCOB = '1' AND BRJ_PRENDC <> ' ' AND BRJ_NRNDC <> ' ') AND BRJ_GERPTU = '1' ))"
	

If MV_PAR05 == 1 
	cPLSFiltro += " AND BRJ_TIPLOT = '2' "
Else
	cPLSFiltro += " AND BRJ_TIPLOT <> '2' "
EndIf 

cPLSFiltro += " AND D_E_L_E_T_ = ' '"

DbSelectArea("BRJ")
SET FILTER TO &cPLSFiltro

BRJ->(MarkBrow("BRJ","BRJ_OK",nil,nil,,cMarcaBRJ,nil,,,,"PLSPA550MR()"))

DbSelectArea("BRJ")
SET FILTER TO

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Pl550Excluir �Autor  �Microsiga        � Data �  03/23/12   ���
�������������������������������������������������������������������������͹��
���Desc.     �Exclus�o da Guias importadas                                ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function Pl550Excluir(nTipoExclu1,lExibe)
LOCAL cAliasTrb	:= GetNextAlias()
LOCAL cChavePes	:=""
LOCAL aRegDelet:={}
LOCAL i:=0
LOCAL lDelTit   := .F.
LOCAL lExcGuia  := .F.
LOCAL lContGer  := .F.
LOCAL nGuiExcl  := 0
LOCAL nGuiNExcl := 0
LOCAL aAreaBTO  := {}
LOCAL lDelR507  := .F.
LOCAL cArqParImp := ""
Default lExibe:=.F.

//��������������������������������������������������������������������������Ŀ
//� Reembolso  - pela BRJ									     �
//����������������������������������������������������������������������������
If nTipoExclu1 = 1 .And. BRJ->BRJ_TIPLOT == "2"
	B7R->(DbSetOrder(1))//B7R_FILIAL+B7R_CODBRJ+B7R_SEQGUI  
	
	If BRJ->BRJ_NIV550 $ "345678" .And. B7R->(DbSeek(xFilial("B7R")+BRJ->BRJ_CODIGO))    
				
		While xFilial("B7R")+B7R->B7R_CODBRJ == xFilial("B7R")+BRJ->BRJ_CODIGO .And. !B7R->(Eof())
			If Empty(B7R->B7R_CONTIT) .And. (B7R->B7R_VLRPNE > 0 .Or. B7R->B7R_VLRGNE > 0 )
				B7R->( RecLock("B7R",.F.) )	
		 		B7R->B7R_VLRPNE := 0
		  		B7R->B7R_VLRGNE := 0
		   		B7R->( MsUnLock() )  
						
				lDelR507 := .T.
			Endif	
			B7R->(DbSkip()) 
		EndDo 

		If lDelR507    
			BRJ->(RecLock("BRJ",.F.))
			//��������������������������������������������������������������������������Ŀ
			//� Quando for Parcial / Integral									 	     �
			//����������������������������������������������������������������������������
			If BRJ->BRJ_NIV550 $ '3|4|5|6'
				If BRJ->BRJ_NIV550 $ '3|4' .And. BRJ->(FieldPos("BRJ_ARQPAR")) > 0 
					If BRJ->BRJ_ARQPAR == "2"
						BRJ->BRJ_ARQPAR := "1"  
						BRJ->BRJ_NIV550 := "3"
					Else
						BRJ->BRJ_ARQPAR := " "
						BRJ->BRJ_NIV550 := "1" 
					EndIf
				Else
					BRJ->BRJ_NIV550 := "1"
				EndIf
				
			//��������������������������������������������������������������������������Ŀ
			//� Quando for Complementar											 	     �
			//����������������������������������������������������������������������������
			ElseIf BRJ->BRJ_NIV550 == "7"
				BRJ->BRJ_NIV550 := "3"
			ElseIf BRJ->BRJ_NIV550 == "8"
				BRJ->BRJ_NIV550 := "4"
			EndIf
			BRJ->BRJ_OK		:=" "
			BRJ->(MsUnLock())   
		EndIf
		
		If lDelR507
			MsgInfo("Cancelamento realizado com suceso.")
		Else
	  		MsgInfo("N�o foi poss�vel realizar o cancelamento. A fatura n�o foi importada ou j� foi paga (gerado arquivo A560).")
		EndIf	
	ElseIf BRJ->BRJ_NIV550 == "1" 
		MsgInfo("O arquivo A550 n�o foi importado.")
	EndIf  
//��������������������������������������������������������������������������Ŀ
//� Reembolso  - pela BTO									     �
//����������������������������������������������������������������������������	
ElseIf nTipoExclu1 = 1 .And. BTO->BTO_REEANE == "1"

	If BTO->BTO_NIV550 $ "2/3/4/5" .And. !Empty(BTO->BTO_GPFTIT)
		MsgInfo("N�o � poss�vel realizar o cancelamento, t�tulo de cobran�a j� gerado: "+BTO->BTO_GPFPRE+" "+BTO->BTO_GPFTIT)	
		Return .F.
	ElseIf BTO->BTO_NIV550 $ "6/7" .And. !Empty(BTO->BTO_GCOTIT)
  		MsgInfo("N�o � poss�vel realizar o cancelamento, t�tulo de cobran�a j� gerado: "+BTO->BTO_GCOPRE+" "+BTO->BTO_GCOTIT)
  		Return .F.
	EndIf     
	
	BTO->(RecLock("BTO",.F.))
	If BTO->BTO_NIV550 $ "7/8"
		BTO->BTO_NIV550 := "5 
		BTO->BTO_SLDGCO := 0
	ElseIf BTO->BTO_NIV550 $ "3/4/5/6"     
		BTO->BTO_NIV550 := "1"
		BTO->BTO_SLDGPF := 0
	EndIf
	BTO->(MsUnlock()) 
	
//��������������������������������������������������������������������������Ŀ
//� Atraves da BRJ														     �
//����������������������������������������������������������������������������
ElseIf nTipoExclu1 = 1
	If BRJ->BRJ_NIV550=="3" .OR. BRJ->BRJ_NIV550=="4" .OR. BRJ->BRJ_NIV550=="5" .Or. BRJ->BRJ_NIV550=="6" .OR. ;
	   BRJ->BRJ_NIV550=="7" .OR. BRJ->BRJ_NIV550=="8"


		//���������������������������������������������������������������������������P�
		//�(BD5)->Verificar no bd5 se h� guias com o numero de regisrtro de importa��a�
		//���������������������������������������������������������������������������P�

		BeginSql Alias cAliasTrb
			SELECT * FROM %table:BD5% BD5
			WHERE BD5.BD5_FILIAL = %exp:xFilial("BD5")% AND BD5.BD5_SEQIMP = %exp:BRJ->BRJ_CODIGO% AND BD5.%notDel%
		Endsql
		BD6->(DbSetOrder(1))
		BD7->(DbSetOrder(1))

		If (cAliasTrb)->(!Eof())
			While (cAliasTrb)->(!Eof())
			    lExcGuia := .F.
			    lContGer := .F.
				If Empty((cAliasTrb)->BD5_GUIORI) .or. (!empty((cAliasTrb)->BD5_GUIORI) .and. substr((cAliasTrb)->BD5_GUIORI,9,8) <> (cAliasTrb)->BD5_CODPEG)
					BD5->(DBGOTO((cAliasTrb)->R_E_C_N_O_))

					If !Empty(BRJ->BRJ_NUMTIT) .Or. !Empty(BRJ->BRJ_NUMNDC) .Or. ;
						  !Empty(BRJ->BRJ_CFTTIT) .Or. !Empty(BRJ->BRJ_CNDTIT)
		
						lContGer := .T.
					EndIf
					//����������������������������������������������������������������������������Ŀ
					//� Nova regra: so atualiza guia se a Contestacao nao foi gerada ainda no A560 �
	   				//������������������������������������������������������������������������������
					If !lContGer
						BD5->(RecLock("BD5",.F.))
						BD5->BD5_SITUAC:="1"
						BD5->BD5_GUESTO := ""
						BD5->BD5_ESTORI := ""
						BD5->(MsUnlock())
						cChavePes  := BD5->(BD5_FILIAL+BD5_CODOPE+BD5_CODLDP+BD5_CODPEG+BD5_NUMERO+BD5_ORIMOV)

						If BD6->(DbSeek(cChavePes))
							While !BD6->(Eof()) .AND. BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV)=cChavePes
								If BD7->(DbSeek(xFilial("BD7")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)))
									
									While ! BD7->(Eof()) .And. BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN) == ;
															xFilial("BD7")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)
									
										BD7->(RecLock("BD7",.F.))
										
											PLBLOPC("BD7", .f., cCodCritica, cDesCritica)
										
											BD7->BD7_SITUAC := "1"
										
										BD7->(MsUnlock())
										
									BD7->(DbSkip())
									Enddo
								Endif
								
								BD6->(RecLock("BD6",.F.))
								
									BD6->BD6_SITUAC := "1"
	
									PLBLOPC("BD6", .f., cCodCritica, cDesCritica, .t., .t., .f. )
									
								BD6->(MsUnlock())
								
							BD6->(DbSkip())
							Enddo
						Endif
					EndIf
				Else

					BD5->(DBGOTO((cAliasTrb)->R_E_C_N_O_))
					cChavePes  := BD5->(BD5_FILIAL+BD5_CODOPE+BD5_CODLDP+BD5_CODPEG+BD5_NUMERO+BD5_ORIMOV)

					If BD6->(DbSeek(cChavePes))
						While !BD6->(Eof()) .AND. BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV)=cChavePes
							//��������������������������������������������������������������������������Ŀ
							//� Nova regra: so exclui guia se a Contestacao nao foi gerada ainda no A560 �
	   						//����������������������������������������������������������������������������
						    If Empty(BD6->BD6_CONTIT) .And. Empty (BD6->BD6_NDCTIT) .Or. BRJ->BRJ_GERPTU == "1"  
						    
								If BD7->(DbSeek(xFilial("BD7")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)))
									While ! BD7->(Eof()) .And. BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN) == ;
										xFilial("BD7")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)
										BD7->(RecLock("BD7",.F.))
										BD7->(DbDelete())
										BD7->(MsUnlock())
										BD7->(DbSkip())
									Enddo
								Endif
								BD6->(RecLock("BD6",.F.))
								BD6->(DbDelete())
								BD6->(MsUnlock())
								lExcGuia := .T.
								nGuiExcl ++
							Else
								nGuiNExcl ++
							EndIf
							BD6->(DbSkip())
						Enddo
					Endif
					//��������������������������������������������������������������������������Ŀ
					//� Nova regra: so altera BD5 se a Contestacao nao foi gerada ainda no A560  �
	   				//����������������������������������������������������������������������������
					If lExcGuia
						BD5->(RecLock("BD5",.F.))
						BD5->(DbDelete())
						BD5->(MsUnlock())
					EndIf
				Endif
				(cAliasTrb)->(Dbskip())
			Enddo
		Endif

		(cAliasTrb)->(DbCloseArea())


		//���������������������������������������������������������������������������P�
		//�(BE4)->Verificar no be4 se h� guias com o numero de regisrtro de importa��a�
		//���������������������������������������������������������������������������P�

		cAliasTrb	:= GetNextAlias()

		BeginSql Alias cAliasTrb
			SELECT * FROM %table:BE4% BE4
			WHERE BE4.BE4_FILIAL = %exp:xFilial("BE4")% AND BE4.BE4_SEQIMP = %exp:BRJ->BRJ_CODIGO% AND BE4.%notDel%
		Endsql
		BD7->(DbSetOrder(1))

		If (cAliasTrb)->(!Eof())
			While (cAliasTrb)->(!Eof())
			    lExcGuia := .F.
				lContGer := .F.
				If empty((cAliasTrb)->BE4_GUIORI) .or. (!empty((cAliasTrb)->BE4_GUIORI) .and. substr((cAliasTrb)->BE4_GUIORI,9,8) <> (cAliasTrb)->BE4_CODPEG)

					If !Empty(BRJ->BRJ_NUMTIT) .Or. !Empty(BRJ->BRJ_NUMNDC) .Or. ;
						  !Empty(BRJ->BRJ_CFTTIT) .Or. !Empty(BRJ->BRJ_CNDTIT)
						  
						lContGer := .T.
					EndIf
					//����������������������������������������������������������������������������Ŀ
					//� Nova regra: so atualiza guia se a Contestacao nao foi gerada ainda no A560 �
	   				//������������������������������������������������������������������������������
					If !lContGer
						BE4->(DBGOTO((cAliasTrb)->R_E_C_N_O_))
						BE4->(RecLock("BE4",.F.))
						BE4->BE4_SITUAC:="1"
						BE4->BE4_GUESTO := ""
						BE4->BE4_ESTORI := ""
						BE4->(MsUnlock())
						cChavePes  := BE4->(BE4_FILIAL+BE4_CODOPE+BE4_CODLDP+BE4_CODPEG+BE4_NUMERO+BE4_ORIMOV)

						If BD6->(DbSeek(cChavePes))
							While !BD6->(Eof()) .AND. BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV)=cChavePes
								If BD7->(DbSeek(xFilial("BD7")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)))
									
									While ! BD7->(Eof()) .And. BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN) == ;
																xFilial("BD7")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)
										
										BD7->(RecLock("BD7",.F.))
											
											PLBLOPC("BD7", .f., cCodCritica, cDesCritica)	
										
											BD7->BD7_SITUAC := "1"
										
										BD7->(MsUnlock())
										
									BD7->(DbSkip())
									Enddo
									
								Endif
								
								BD6->(RecLock("BD6",.F.))
									
									PLBLOPC("BD6", .f., cCodCritica, cDesCritica, .t., .t., .f. )
									
									BD6->BD6_SITUAC := "1"
									
								BD6->(MsUnlock())
								
							BD6->(DbSkip())
							Enddo
						Endif
					EndIf
				Else

					BE4->(DBGOTO((cAliasTrb)->R_E_C_N_O_))
					cChavePes  := BE4->(BE4_FILIAL+BE4_CODOPE+BE4_CODLDP+BE4_CODPEG+BE4_NUMERO+BE4_ORIMOV)

					If BD6->(DbSeek(cChavePes))
						While !BD6->(Eof()) .AND. BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV)=cChavePes
							//��������������������������������������������������������������������������Ŀ
							//� Nova regra: so exclui guia se a Contestacao nao foi gerada ainda no A560 �
	   						//����������������������������������������������������������������������������
						    If Empty(BD6->BD6_CONTIT) .And. Empty(BD6->BD6_NDCTIT) .Or. BRJ->BRJ_GERPTU == "1" 
							    
								If BD7->(DbSeek(xFilial("BD7")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)))
									While ! BD7->(Eof()) .And. BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN) == ;
										xFilial("BD7")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)
										BD7->(RecLock("BD7",.F.))
										BD7->(DbDelete())
										BD7->(MsUnlock())
										BD7->(DbSkip())
									Enddo
								Endif
								BD6->(RecLock("BD6",.F.))
								BD6->(DbDelete())
								BD6->(MsUnlock())
								lExcGuia := .T.
								nGuiExcl ++
							Else
								nGuiNExcl ++
							EndIf
							BD6->(DbSkip())
						Enddo
					Endif
					//��������������������������������������������������������������������������Ŀ
					//� Nova regra: so altera BD5 se a Contestacao nao foi gerada ainda no A560  �
	   				//����������������������������������������������������������������������������
					If lExcGuia
						BE4->(RecLock("BE4",.F.))
						BE4->(DbDelete())
						BE4->(MsUnlock())
					EndIf
				Endif
				(cAliasTrb)->(Dbskip())
			Enddo
		Endif
		(cAliasTrb)->(DbCloseArea())

		If nGuiExcl > 0
			BRJ->(RecLock("BRJ",.F.))
			//��������������������������������������������������������������������������Ŀ
			//� Ajuste de indicador de fatura parcial							 	     �
			//����������������������������������������������������������������������������
			If BRJ->(FieldPos("BRJ_ARQPAR")) > 0
				cArqParImp := BRJ->BRJ_ARQPAR 
				If BRJ->BRJ_NIV550 $ "3|4" .And. (BRJ->BRJ_ARQPAR == "1" .Or. Empty(BRJ->BRJ_ARQPAR))
					BRJ->BRJ_ARQPAR := ""	
				ElseIf BRJ->BRJ_NIV550 $ "3|4" .And. BRJ->BRJ_ARQPAR == "2"
					BRJ->BRJ_ARQPAR := "1"
				EndIf
			EndIf
			//��������������������������������������������������������������������������Ŀ
			//� Quando for Parcial / Integral									 	     �
			//����������������������������������������������������������������������������
			If BRJ->BRJ_NIV550 $ '3|4|5|6'
				If !(Alltrim(mv_par01) >= "A550G" .And. cArqParImp == "2")
				BRJ->BRJ_NIV550 := "1"
				EndIf	
			//��������������������������������������������������������������������������Ŀ
			//� Quando for Complementar											 	     �
			//����������������������������������������������������������������������������
			ElseIf BRJ->BRJ_NIV550 = "7"
				BRJ->BRJ_NIV550 := "3"
			ElseIf BRJ->BRJ_NIV550 = "8"
				BRJ->BRJ_NIV550 := "4"
			EndIf
			BRJ->BRJ_OK		:=" "
			BRJ->(MsUnLock())

			MsgInfo(STR0055,STR0051)
			lDelTit := .T.
		ElseIf nGuiNExcl > 0
			MsgInfo(STR0061)//"N�o foi poss�vel efetuar o cancelamento, t�tulo de contesta��o j� gerado"
		EndIf
	Endif


//��������������������������������������������������������������������������Ŀ
//� Atraves da BTO														     �
//����������������������������������������������������������������������������
ElseIf nTipoExclu1 = 2

		//���������������������������������������������������������������������������P�
		//�(BTO)->Verificar no be4 se h� guias com o numero de regisrtro de importa��a�
		//���������������������������������������������������������������������������P�

		cAliasTrb	:= GetNextAlias()

		BD5->(DbSetOrder(1))
		BE4->(DbSetOrder(1))
		
		If BTO->BTO_TPMOV == "3"
			aAreaBTO := BTO->(GetArea())
			BTO->(DbSetOrder(1))//BTO_FILIAL + BTO_CODOPE + BTO_NUMERO + BTO_OPEORI
			cChaveBTO := BTO->(BTO_FILIAL + BTO_CODOPE + BTO_NUMERO + BTO_OPEORI)
			If BTO->(DbSeek(cChaveBTO)) 

				While BTO->(BTO_FILIAL + BTO_CODOPE + BTO_NUMERO + BTO_OPEORI) == cChaveBTO .And. !BTO->(Eof()) 
	
				   	//��������������������������������������������������������������������������Ŀ    
					//� Nova regra manual de intercambio (Flaga o BTO_TPMOV)   					 �
					//� 2 = DOC_1 (Valor do Item + Taxa Administrativa)     					 �
					//� 3 = DOC_1 (Taxa Administrativa) + DOC_2 (Valor do Item)					 �
					//����������������������������������������������������������������������������     
					If BTO->BTO_TPCOB == "1" //NDC-Servicos -> DOC2
						cNumNDC := BTO->BTO_NUMTIT
						cPreNDC := BTO->BTO_PREFIX 
						  
						If BTO->(FieldPos("BTO_ARQPAR")) > 0 .And. BTO->BTO_ARQPAR == "2" .And. BTO->BTO_NIV550 $ "3/4" 
							If !Empty(BTO->BTO_GP2TIT)   
								MsgInfo("N�o � poss�vel realizar o cancelamento, t�tulo de cobran�a j� gerado: "+BTO->BTO_GP2PRE+" "+BTO->BTO_GP2TIT)	
								Return .F.
							EndIf
						ElseIf BTO->BTO_NIV550 $ "3/4/5/6" .And. !Empty(BTO->BTO_GPFTIT)
							MsgInfo("N�o � poss�vel realizar o cancelamento, t�tulo de cobran�a j� gerado: "+BTO->BTO_GPFPRE+" "+BTO->BTO_GPFTIT)	
							Return .F.
						ElseIf BTO->BTO_NIV550 $ "7/8" .And. !Empty(BTO->BTO_GCOTIT)
					  		MsgInfo("N�o � poss�vel realizar o cancelamento, t�tulo de cobran�a j� gerado: "+BTO->BTO_GCOPRE+" "+BTO->BTO_GCOTIT)
					  		Return .F.
						EndIf
					    
					ElseIf BTO->BTO_TPCOB == "2" //Fatura-Taxas -> DOC1	  
						cNumTit := BTO->BTO_NUMTIT
						cPrefix := BTO->BTO_PREFIX 
						
						If BTO->(FieldPos("BTO_ARQPAR")) > 0 .And. BTO->BTO_ARQPAR == "2" .And. BTO->BTO_NIV550 $ "3/4" 
							If !Empty(BTO->BTO_GP2TIT)   
								MsgInfo("N�o � poss�vel realizar o cancelamento, t�tulo de cobran�a j� gerado: "+BTO->BTO_GP2PRE+" "+BTO->BTO_GP2TIT)	
								Return .F.
							EndIf
						ElseIf BTO->BTO_NIV550 $ "3/4/5/6" .And. !Empty(BTO->BTO_GPFTIT)
							MsgInfo("N�o � poss�vel realizar o cancelamento, t�tulo de cobran�a j� gerado: "+BTO->BTO_GPFPRE+" "+BTO->BTO_GPFTIT)	
							Return .F.
						ElseIf BTO->BTO_NIV550 $ "7/8" .And. !Empty(BTO->BTO_GCOTIT)
					  		MsgInfo("N�o � poss�vel realizar o cancelamento, t�tulo de cobran�a j� gerado: "+BTO->BTO_GCOPRE+" "+BTO->BTO_GCOTIT)
					  		Return .F.
						EndIf
					EndIf   
		
					BTO->(DbSkip())
				EndDo
			EndIf
			RestArea(aAreaBTO)	
		Else
			cNumTit := BTO->BTO_NUMTIT
			cPrefix := BTO->BTO_PREFIX
			
			If BTO->(FieldPos("BTO_ARQPAR")) > 0 .And. BTO->BTO_ARQPAR == "2" .And. BTO->BTO_NIV550 $ "3/4" 
				If !Empty(BTO->BTO_GP2TIT)   
					MsgInfo("N�o � poss�vel realizar o cancelamento, t�tulo de cobran�a j� gerado: "+BTO->BTO_GP2PRE+" "+BTO->BTO_GP2TIT)	
					Return .F.
				EndIf
			ElseIf BTO->BTO_NIV550 $ "3/4/5/6" .And. !Empty(BTO->BTO_GPFTIT)
				MsgInfo("N�o � poss�vel realizar o cancelamento, t�tulo de cobran�a j� gerado: "+BTO->BTO_GPFPRE+" "+BTO->BTO_GPFTIT)	
				Return .F.
			ElseIf BTO->BTO_NIV550 $ "7/8" .And. !Empty(BTO->BTO_GCOTIT)
		  		MsgInfo("N�o � poss�vel realizar o cancelamento, t�tulo de cobran�a j� gerado: "+BTO->BTO_GCOPRE+" "+BTO->BTO_GCOTIT)
		  		Return .F.
			EndIf
		EndIf
          
        /*��������������������������������������������������������������������������Ŀ
		//� Comentei esse trecho pq acredito que ninguem utiliza a importacao como   �   
		//� Unimed Executora. A query abaixo buscava o titulo de na BD6 mas posso    �	
		//� cancelar sem o titulo gerado, sendo assim, estava incorreta.             �
		//� Foi realizado ajuste para importar e pagar quando minha Unimed Executora �	
		//� para a Vale dos Sinos. Esse processo sera realizado quando a Executora   �	
		//� tiver valores para receber da Origem                                     �	
		//����������������������������������������������������������������������������
        If (BTO->BTO_TPMOV == '3' .And. BTO->BTO_TPCOB == '1') .Or. BTO->BTO_TPMOV == '1'
		  	BeginSql Alias cAliasTrb
				SELECT * FROM %table:BD6% BD6
				WHERE BD6.BD6_FILIAL = %exp:xFilial("BD6")% AND BD6.BD6_PRENDC = %exp:BTO->BTO_PREFIX% AND BD6.BD6_NUMNDC = %exp:BTO->BTO_NUMTIT%
				AND BD6.BD6_PARNDC = %exp:BTO->BTO_PARCEL% AND BD6.BD6_TIPNDC = %exp:BTO->BTO_TIPTIT%  AND BD6.BD6_FASE ='3' AND BD6.%notDel%
				ORDER BY BD6.BD6_FILIAL,BD6.BD6_CODOPE,BD6.BD6_CODLDP,BD6.BD6_CODPEG,BD6.BD6_NUMERO,BD6.BD6_SEQUEN,BD6.BD6_CODPAD,BD6.BD6_CODPRO
			Endsql
		Else
			BeginSql Alias cAliasTrb
				SELECT * FROM %table:BD6% BD6
				WHERE BD6.BD6_FILIAL = %exp:xFilial("BD6")% AND BD6.BD6_PREFIX = %exp:BTO->BTO_PREFIX% AND BD6.BD6_NUMTIT = %exp:BTO->BTO_NUMTIT%
				AND BD6.BD6_PARCEL = %exp:BTO->BTO_PARCEL% AND BD6.BD6_TIPTIT = %exp:BTO->BTO_TIPTIT%  AND BD6.BD6_FASE ='3' AND BD6.%notDel%
				ORDER BY BD6.BD6_FILIAL,BD6.BD6_CODOPE,BD6.BD6_CODLDP,BD6.BD6_CODPEG,BD6.BD6_NUMERO,BD6.BD6_SEQUEN,BD6.BD6_CODPAD,BD6.BD6_CODPRO
			Endsql
		Endif */     
		If BTO->BTO_TPMOV == "3"   
			BeginSql Alias cAliasTrb
				SELECT * FROM %table:BD6% BD6
			    WHERE BD6.BD6_FILIAL = %exp:xFilial("BD6")% AND BD6.BD6_NUMNDC = %exp:cNumNDC% AND BD6.BD6_PRENDC = %exp:cPreNDC%    
			    AND BD6.BD6_NUMTIT = %exp:cNumTit% AND BD6.BD6_PREFIX = %exp:cPrefix%
			    AND BD6.BD6_GUIORI <> ' ' AND BD6.%notDel%
			    AND BD6.BD6_CONTIT = ' ' AND BD6.BD6_NDCTIT = ' ' 
			Endsql  
		Else
			BeginSql Alias cAliasTrb
				SELECT * FROM %table:BD6% BD6
			    WHERE BD6.BD6_FILIAL = %exp:xFilial("BD6")% AND BD6.BD6_NUMTIT = %exp:cNumTit% AND BD6.BD6_PREFIX = %exp:cPrefix% 
			    AND BD6.BD6_GUIORI <> ' ' AND BD6.%notDel%
			    AND BD6.BD6_CONTIT = ' ' AND BD6.BD6_NDCTIT = ' '
			Endsql  
		Endif
        
		While (cAliasTrb)->(!Eof())
			cChavePes  := (cAliasTrb)->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO)
			If	!((cAliasTrb)->(BD6_TIPGUI)$ "03#05#11") //NAO E INTERNA��O
				BD5->(DbGotop())
				If BD5->(DbSeek(cChavePes))//depois da clonagem eu deixo posicionado na guia origem
				   If !Empty(BD5->BD5_GUIORI) .and. substr(BD5->BD5_GUIORI,9,8) == BD5->BD5_CODPEG
					   AADD(aRegDelet,{BD5->(RECNO()),"BD5"})
						BD6->(DbGoTo((cAliasTrb)->(R_E_C_N_O_)))
						If BD7->(DbSeek(xFilial("BD7")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)))
							While ! BD7->(Eof()) .And. BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN) == ;
								xFilial("BD7")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)
								BD7->(RecLock("BD7",.F.))
								BD7->(DbDelete())
								BD7->(MsUnlock())
								BD7->(DbSkip())
							Enddo
						Endif

						BD6->(RecLock("BD6",.F.))
						BD6->(DbDelete())
						BD6->(MsUnlock())
				   Endif
				Endif
			Else
				BE4->(DbGotop())
				If BE4->(DbSeek(cChavePes))
				   If !Empty(BE4->BE4_GUIORI) .and. substr(BE4->BE4_GUIORI,9,8) == BE4->BE4_CODPEG
					   AADD(aRegDelet,{BE4->(RECNO()),"BE4"})
   						BD6->(DbGoTo((cAliasTrb)->(R_E_C_N_O_)))

						If BD7->(DbSeek(xFilial("BD7")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)))
							While ! BD7->(Eof()) .And. BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN) == ;
								xFilial("BD7")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)
								BD7->(RecLock("BD7",.F.))
								BD7->(DbDelete())
								BD7->(MsUnlock())
								BD7->(DbSkip())
							Enddo
						Endif

						BD6->(RecLock("BD6",.F.))
						BD6->(DbDelete())
						BD6->(MsUnlock())
				   Endif
				Endif
			Endif
			(cAliasTrb)->(Dbskip())
		Enddo

		For i:=1 to Len(aRegDelet)
			If aRegDelet[i,2]="BD5"
				BD5->(DbGoTo(aRegDelet[i,1]))
				BD5->(RecLock(aRegDelet[i,2],.F.))
				BD5->(DbDelete())
				BD5->(MsUnlock())
			Else
				BE4->(DbGoTo(aRegDelet[i,1]))
				BE4->(RecLock(aRegDelet[i,2],.F.))
				BE4->(DbDelete())
				BE4->(MsUnlock())
			Endif

		Next i


		(cAliasTrb)->(DbCloseArea())
		aRegDelet:={}
		//��������������������������������������������������������������������������Ŀ
		//� Ajusta BTO_NIV550                                              			 �
		//���������������������������������������������������������������������������� 
		aAreaBTO := BTO->(GetArea())
		BTO->(DbSetOrder(1))//BTO_FILIAL + BTO_CODOPE + BTO_NUMERO + BTO_OPEORI
		cChaveBTO := BTO->(BTO_FILIAL + BTO_CODOPE + BTO_NUMERO + BTO_OPEORI)
		If BTO->(DbSeek(cChaveBTO)) 
	
			While BTO->(BTO_FILIAL + BTO_CODOPE + BTO_NUMERO + BTO_OPEORI) == cChaveBTO .And. !BTO->(Eof()) 
	
				BTO->(RecLock("BTO",.F.))
				
				If BTO->BTO_NIV550 $ "7/8"
					If BTO->BTO_NIV550 == "8"
						BTO->BTO_NIV550 := "4"
					ElseIf BTO->BTO_NIV550 == "7"
					  	BTO->BTO_NIV550 := "3"
					EndIf	
					BTO->BTO_SLDGCO := 0
					
				ElseIf BTO->BTO_NIV550 $ "3/4/5/6"     
					//��������������������������������������������������������������������������Ŀ
					//� Ajuste de indicador de fatura parcial							 	     �
					//����������������������������������������������������������������������������
					If BTO->(FieldPos("BTO_ARQPAR")) > 0
						cArqParImp := BTO->BTO_ARQPAR 
						If BTO->BTO_NIV550 $ "3|4" .And. (BTO->BTO_ARQPAR == "1" .Or. Empty(BTO->BTO_ARQPAR))
							BTO->BTO_ARQPAR := " "	
						ElseIf BTO->BTO_NIV550 $ "3|4" .And. BTO->BTO_ARQPAR == "2"
							BTO->BTO_ARQPAR := "1"
						EndIf
					EndIf
					
					If !(Alltrim(mv_par01) >= "A550G" .And. cArqParImp == "2")
					BTO->BTO_NIV550 := "1"
					BTO->BTO_SLDGPF := 0
					ElseIf BTO->(FieldPos("BTO_SLDGP2")) > 0
				 		BTO->BTO_SLDGP2 := 0
					EndIf

				EndIf
					
				BTO->(MsUnlock())
			
				BTO->(DbSkip())
			EndDo
		EndIf
		RestArea(aAreaBTO)	
			
		If lExibe
			MsgInfo(STR0055,STR0051) //"Cancelamento conclu�do","Aten��o"
		Endif
Endif
//��������������������������������������������������������������������������Ŀ
//� Se tipo 6 para Origem, cancela a baixa realizada na contestacao			 �
//����������������������������������������������������������������������������
If nOpcaImp == 6  .And. lDelTit //.And. MV_PAR04 == 2
	SE1->(DbSetOrder(1))//E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
	If !Empty(BRJ->(BRJ_PREFIX+BRJ_NUMTIT+BRJ_PARCEL+BRJ_TIPTIT))

		If SE1->(DbSeek(xFilial("SE1")+BRJ->(BRJ_PREFIX+BRJ_NUMTIT+BRJ_PARCEL+BRJ_TIPTIT))) .And. SE1->E1_STATUS == 'B'
			nRet := PLP550BXCA()
			MsgInfo(Iif(nRet==5,"Cancelada","Exclu�da")+" a baixa do t�tulo de contesta��o "+BRJ->BRJ_PREFIX+" "+BRJ->BRJ_NUMTIT+" "+BRJ->BRJ_TIPTIT)
		Else
		    MsgInfo("T�tulo de contesta��o "+BRJ->BRJ_PREFIX+" "+BRJ->BRJ_NUMTIT+" "+BRJ->BRJ_TIPTIT+" n�o encontrado.")
		EndIf

	EndIf

	If !Empty(BRJ->(BRJ_PRENDC+BRJ_NUMNDC+BRJ_PARNDC+BRJ_TIPNDC))
		
        If SE1->(DbSeek(xFilial("SE1")+BRJ->(BRJ_PRENDC+BRJ_NUMNDC+BRJ_PARNDC+BRJ_TIPNDC))) .And. SE1->E1_STATUS == 'B'
			PLP550BXCA()
			MsgInfo("Exclu�da a baixa do t�tulo de contesta��o "+BRJ->BRJ_PRENDC+" "+BRJ->BRJ_NUMNDC+" "+BRJ->BRJ_TIPNDC)
		Else
		    MsgInfo("T�tulo de contesta��o "+BRJ->BRJ_PRENDC+" "+BRJ->BRJ_NUMNDC+" "+BRJ->BRJ_TIPNDC+" n�o encontrado.")
		EndIf

	EndIf

EndIf

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �TelaResumo�Autor  �Microsiga           � Data �  03/26/12   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/



Static Function TelaResumo()

Local	oDlg2		:= nil
Local 	cTitulo		:= STR0056
Local   oLbx		:=nil

If Len(aResumo)=0
	aResumo:=Array(1,5)
Endif

DEFINE MSDIALOG oDlg2 TITLE cTitulo FROM 0,0 TO 240,500 PIXEL

@ 10,10 LISTBOX oLbx FIELDS HEADER " Peg  ", "Guia original", "Guia Clonada", "Local", "Status"   SIZE 230,95 OF oDlg2 PIXEL

oLbx:SetArray( aResumo )
oLbx:bLine := {|| {aResumo[oLbx:nAt,1],aResumo[oLbx:nAt,2],aResumo[oLbx:nAt,3],aResumo[oLbx:nAt,4],aResumo[oLbx:nAt,5]}}


DEFINE SBUTTON FROM 107,213 TYPE 1 ACTION oDlg2:End() ENABLE OF oDlg
ACTIVATE MSDIALOG oDlg2 CENTER

aResumo := {}

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PL550Imp6 �Autor  �Microsiga           � Data �  03/16/12   ���
�������������������������������������������������������������������������͹��
���Desc.     �Importa o tipo 6 com base no BRJ 	que foi enviado o tipo 1  ���
���          �Atualizara as glosas (todas foram contestadas)              ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PL550Imp6()

LOCAL cPLSFiltro  := ""

cPLSFiltro := "@BRJ_FILIAL = '"+xFilial("BRJ")+"' AND BRJ_REGPRI = '1' "
cPLSFiltro += " AND ((BRJ_PREFIX <> ' ' AND BRJ_NUMTIT <> ' ') OR (BRJ_TPCOB = '1' AND BRJ_PRENDC <> ' ' AND BRJ_NRNDC <> ' '))"
cPLSFiltro += " AND D_E_L_E_T_ = ' '"

DbSelectArea("BRJ")
SET FILTER TO &cPLSFiltro

BRJ->(MarkBrow("BRJ","BRJ_OK",nil,nil,,cMarcaBRJ,nil,,,,"PLSPA550MR()"))

DbSelectArea("BRJ")
SET FILTER TO

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PLP550BXCA�Autor  �TOTVS               � Data �  16/06/13   ���
�������������������������������������������������������������������������͹��
���Desc.     �Executa baixa de titulos por cancelamento quando o titulo   ���
���          �nao puder ser excluido na exclusao do lote.                 ���
�������������������������������������������������������������������������͹��
���Uso       � O titulo deve estar posicionado...                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function PLP550BXCA()
LOCAL aVetor      := {}
LOCAL cMvPar01    := MV_PAR01
LOCAL cMvPar02    := MV_PAR02
LOCAL cMvPar03    := MV_PAR03
LOCAL cMvPar04    := MV_PAR04
LOCAL cMvPar05    := MV_PAR05

Local oDlg
Local aOPC := {}
Local nRadio := 1
Local oRadio
Local bBlock := { |x| Iif( ValType( x ) == 'U', nRadio, nRadio:=x ) }

PRIVATE cNumTit   := SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA
PRIVATE dBaixa    := If(dDataBase < SE1->E1_EMISSAO, SE1->E1_EMISSAO, dDatabase)
PRIVATE cTipo     := SE1->E1_TIPO
PRIVATE cNsNum    := " "
PRIVATE dDataCred := SE1->E1_EMISSAO
PRIVATE nDespes   := 0
PRIVATE nDescont  := 0
PRIVATE nValRec   := SE1->E1_SALDO
PRIVATE nJuros    := 0
PRIVATE nMulta    := 0
PRIVATE nCM       := 0
PRIVATE nAcresc   := 0
PRIVATE nDescresc := 0
PRIVATE nTotAbat  := 0
PRIVATE cLoteFin  := ""
PRIVATE cMarca    := ""
PRIVATE cMotBx    := getNewPar("MV_PLMOTBC","CAN")
PRIVATE cHist070  := "Titulo cancelado pelo Plano de Saude."
PRIVATE cBanco    := ""
PRIVATE cAgencia  := ""
PRIVATE cConta    := ""
PRIVATE nValEstrang

//NAO RETIRAR ESSA VARIAVEL DAQUI,ELA EH USADA DENTRO DO FINA070...           
nValEstrang := 0

//Testa integridade do titulo...                                             
If !SE1->( deleted() ) .and. SE1->( !eof() )
	
    aAdd( aOPC, "Cancelar baixa"      )
    aAdd( aOPC, "Excluir baixa"       )

    DEFINE MSDIALOG oDlg TITLE "Deseja cancelar ou excluir a baixa?" FROM 0,0 TO 150,285 OF oDlg PIXEL
    @ 4, 5 TO 60,140 LABEL  " Selecione " OF oDlg PIXEL
    oRadio := TRadMenu():New( 12, 10, aOPC, bBlock, oDlg, , NIL, , , , , ,80 ,10 )
    @ 60,108 BUTTON "&Ok"     SIZE 32,10 PIXEL ACTION oDlg:End()
    ACTIVATE MSDIALOG oDlg CENTER

    If nRadio == 1
        nOpc := 5 //cancela a baixa
    Else
        nOpc := 6 //exclui a baixa
    EndIf

    //Baixa titulo no Contas a Receber                                           
    lMsErroAuto := .F.
    
    aVetor  := {	{"E1_PREFIXO"	,SE1->E1_PREFIXO		,Nil},;
                    {"E1_NUM"		,SE1->E1_NUM			,Nil},;
                    {"E1_PARCELA"	,SE1->E1_PARCELA		,Nil},;
                    {"E1_TIPO"		,SE1->E1_TIPO			,Nil},;
                    {"E1_NATUREZ"	,SE1->E1_NATUREZ		,Nil},;
                    {"E1_CLIENTE"	,SE1->E1_CLIENTE		,Nil}}

    MSExecAuto({|x,y| Fina070(x,y)}, aVetor, nOpc) //Exclusao

    If lMsErroAuto
        MOSTRAERRO()
    Endif

EndIf

//Fim da rotina de baixa de titulos por cancelamento...                      
MV_PAR01 := cMvPar01
MV_PAR02 := cMvPar02
MV_PAR03 := cMvPar03
MV_PAR04 := cMvPar04
MV_PAR05 := cMvPar05

Return(nOpc)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PL550PesqTit�Autor  �TOTVS            � Data �  16/06/13   ���
�������������������������������������������������������������������������͹��
���Desc.     �Pesquisa e realiza posicionamento do browse pelo titulo     ���
�������������������������������������������������������������������������͹��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function PL550PesqTit()
Local cTitulo	:= STR0062			//'Pesquisa por Prefixo+T�tulo+Parc+Tipo'
Local oLbx		:= NIL
Local cGetTit	:= Space(30)
Private oDlg2	:= nil

DEFINE MSDIALOG oDlg2 TITLE cTitulo FROM 0,0 TO 100,300 PIXEL
@ 010,010 GET cGetTit Picture '@!' OF oDlg2 SIZE 130,010 PIXEL
DEFINE SBUTTON FROM 030,010 TYPE 1 ACTION MsAguarde( {|| PesqTitLt(AllTrim(cGetTit),1) }, STR0063, "", .T. ) ENABLE OF oDlg2		// "Pesquisando" 
ACTIVATE MSDIALOG oDlg2 CENTER

Return


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PLP550PesqLot�Autor  �TOTVS            � Data �  16/06/13   ���
�������������������������������������������������������������������������͹��
���Desc.     �Pesquisa e realiza posicionamento do browse pelo lote       ���
�������������������������������������������������������������������������͹��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function PL550PesqLot()
Local cTitulo	:= STR0064 		// 'Pesquisa por Lote'
Local oLbx		:= NIL
Local cGetTit	:= Space(30)
Private oDlg2		:= nil

DEFINE MSDIALOG oDlg2 TITLE cTitulo FROM 0,0 TO 100,300 PIXEL
@ 010,010 GET cGetTit Picture '@!' OF oDlg2 SIZE 130,010 PIXEL
DEFINE SBUTTON FROM 030,010 TYPE 1 ACTION MsAguarde( {|| PesqTitLt(AllTrim(cGetTit),2) }, STR0063, "", .T. ) ENABLE OF oDlg2		// "Pesquisando"
ACTIVATE MSDIALOG oDlg2 CENTER

Return


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PLP550PesqLot�Autor  �TOTVS            � Data �  16/06/13   ���
�������������������������������������������������������������������������͹��
���Desc.     �Pesquisa e realiza posicionamento do browse pelo lote       ���
�������������������������������������������������������������������������͹��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function PesqTitLt(cPesquisa,nTipo) 
Default cPesquisa	:= ''
Default nTipo		:= ''

oDlg2:End()
If nTipo == 1				// Pesquisa por Pref+T�tulo+Parc+Tipo
	BTO->(dbSetOrder(3))
	dbSeek(xFilial('BTO')+cPesquisa, .T.)
Else						// Pesquisa por Lote
	BTO->(dbSetOrder(2))
	dbSeek(xFilial('BTO')+PlsIntPad()+cPesquisa, .T.)
EndIf

Return
                
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ImpReemAne�Autor  �TOTVS               � Data �  19/10/15   ���
�������������������������������������������������������������������������͹��
���Desc.     � Importa reembolso                            ���
�������������������������������������������������������������������������͹��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ImpReemAne(cTpArq,aGuias,nTipoOpe,cArqPar)
Local nI        := 0  
Local aOk       := {}
Local cNota     := "" 
Local cSeqA500  := ""   
Local cGuiaAtu  := ""
Local nVlrAcord := 0
Default cArqPar := ""

B7R->(DbSetOrder(2))//B7R_FILIAL+B7R_CODBRJ+B7R_NRSEQ, R_E_C_N_O_, D_E_L_E_T_
//����������������������������������������������������������������������������Ŀ
//� Origem Beneficiario - Lote pela BTO                                        �
//������������������������������������������������������������������������������
If nTipoOpe == 2    
	For nI := 1 to len(aGuias) 
		If Alltrim(aGuias[nI][5]) $ "01|02|13|14"    
			nVlrAcord += aGuias[nI][3]
		EndIf	
	Next		
	
	If nVlrAcord > 0 
		BTO->( RecLock("BTO",.F.) )	
		If alltrim(STR(nOpcaImp)) $ "3/4/5/6"
			If Alltrim(mv_par01) >= "A550G" .And. BTO->(FieldPos("BTO_ARQPAR")) > 0 .And. alltrim(STR(nOpcaImp)) $ "3/4"
	    		BTO->BTO_ARQPAR := cArqPar 
	    		If cArqPar == "1"
			BTO->BTO_SLDGPF  := nVlrAcord
	    		ElseIf cArqPar == "2" 
	    			BTO->BTO_SLDGP2  := nVlrAcord
	    		EndIf	
	    	Else
				BTO->BTO_SLDGPF  := nVlrAcord
			EndIf	
	    ElseIf alltrim(STR(nOpcaImp)) $ "7/8" 
		    BTO->BTO_SLDGCO  := nVlrAcord
	    EndIf 
	    BTO->BTO_NIV550 := alltrim(STR(nOpcaImp))
	    
	    
	    BTO->( MsUnLock() )
	EndIf	
//����������������������������������������������������������������������������Ŀ
//� Origem Prestador - Lote pela BRJ                                           �
//������������������������������������������������������������������������������
Else
	For nI := 1 to len(aGuias)     
		cNota    := Alltrim(aGuias[nI][6])
	    cSeqA500 := Alltrim(aGuias[nI][1])
	    cGuiaAtu := "N�o"
	    
		If B7R->(DbSeek(xFilial("B7R")+BRJ->BRJ_CODIGO+cSeqA500)) .And. Alltrim(aGuias[nI][5]) $ "01|02|13|14"
			B7R->( RecLock("B7R",.F.) )	
			B7R->B7R_VLRPNE := aGuias[nI][2] //16 VL_RECONH_SERV
			B7R->B7R_VLRGNE := aGuias[nI][3] //17 VL_ACORDO_SERV   
			B7R->( MsUnLock() )  
			cGuiaAtu := "Sim"
		Endif    
	    	
		AaDd(aOK,{cNota,cSeqA500,cGuiaAtu})
	                                                   
		BRJ->( RecLock("BRJ",.F.) )	
		BRJ->BRJ_NIV550 := cValtoChar(cTpArq)
		If alltrim(STR(nOpcaImp)) $ "3/4"
			BRJ->BRJ_ARQPAR := cArqPar 
		Endif
		BRJ->( MsUnLock() )
		
	Next
EndIf

MsgInfo("Importa��o realizada com sucesso.")
//PLSCRIGEN(aOK,{ {"Nota","@C",20},{"Sequenc. A500","@C",8},{"Guia Atualizada","@C",3} }, "Resumo") //"Operadora Origem"###"Status"###"Arquivo Gerado"###"  Resumo "

Return()    

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ValidImp  �Autor  �TOTVS               � Data �  19/10/15   ���
�������������������������������������������������������������������������͹��
���Desc.     � Importa reembolso                            			  ���
�������������������������������������������������������������������������͹��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ValidImp(cAlias,nOpcaImp,cArqPar)
Local lRet := .T.

If Alltrim(mv_par01) >= "A550G" .And. nOpcaImp == 3 .And. cAlias == "BRJ" .And. BRJ->BRJ_NIV550 == '1' .And. cArqPar == "2" .And. ;
	Empty(BRJ->BRJ_NUMTIT) .And. Empty(BRJ->BRJ_PREFIX)     
   
	Aviso("O processamento n�o pode ser realizado","Ainda n�o foi importado o arquivo Parcial 1, � necess�rio import�-lo antes de importar a Parcial 2",{"Fechar"})
	lRet := .F.
EndIf

If  nOpcaImp == 3 .AND. &(cAlias+"->"+cAlias+"_NIV550") == '3'   //Tipo 3
	If Alltrim(mv_par01) >= "A550G" 
		If  &(cAlias+"->"+cAlias+"_ARQPAR") == "1" .And. cArqPar == "1" .Or. &(cAlias+"->"+cAlias+"_ARQPAR") == "2" 
			Aviso("O processamento n�o pode ser realizado","O arquivo parcial "+cArqPar+" j� foi importado"+STR0058,{"Fechar"})
    lRet := .F.
		EndIf 
		If cAlias == "BRJ" 
			If cArqPar == "2" .And. Empty(BRJ->BRJ_NUMTIT) .And. Empty(BRJ->BRJ_PREFIX)     
				Aviso("O processamento n�o pode ser realizado","N�o foi gerado o t�tulo da importa��o parcial 1. Para continuar, gere o t�tulo atrav�s da gera��o do PTU A560.",{"Fechar"})
				lRet := .F.
			EndIf
		EndIf
	Else
		Aviso("O processamento n�o pode ser realizado",STR0057+"3"+STR0058,{"Fechar"})
	    lRet := .F.
    EndIf
Endif

If  nOpcaImp == 4 .AND. &(cAlias+"->"+cAlias+"_NIV550") == '4'   //Tipo 4
	If Alltrim(mv_par01) >= "A550G" 
		If  &(cAlias+"->"+cAlias+"_ARQPAR") == "1" .And. cArqPar == "1" .Or. &(cAlias+"->"+cAlias+"_ARQPAR") == "2" 
			Aviso("O processamento n�o pode ser realizado","O arquivo parcial "+cArqPar+" j� foi importado"+STR0058,{"Fechar"})
	lRet := .F.
		EndIf
	Else
		Aviso("O processamento n�o pode ser realizado",STR0057+"4"+STR0058,{"Fechar"})//"Item j� importado como tipo ###", caso queira importar o mesmo dedever� ser excluido e depois importado novamente" 
		lRet := .F.  
	EndIf
Endif

If  nOpcaImp == 5 .AND. &(cAlias+"->"+cAlias+"_NIV550") == '5'   //Tipo 5
	Aviso("O processamento n�o pode ser realizado",STR0057+"5"+STR0058,{"Fechar"})//"Item j� importado como tipo ###", caso queira importar o mesmo dedever� ser excluido e depois importado novamente" 
	lRet := .F.
Endif
If  nOpcaImp == 6 .AND. &(cAlias+"->"+cAlias+"_NIV550") == '6'   //Tipo 6
	Aviso("O processamento n�o pode ser realizado",STR0057+"6"+STR0058,{"Fechar"})//"Item j� importado como tipo ###", caso queira importar o mesmo dedever� ser excluido e depois importado novamente" 
	lRet := .F.
Endif
If  nOpcaImp == 7 .AND. &(cAlias+"->"+cAlias+"_NIV550") == '7'   //Tipo 7
	Aviso("O processamento n�o pode ser realizado",STR0057+"7"+STR0058,{"Fechar"})//"Item j� importado como tipo ###", caso queira importar o mesmo dedever� ser excluido e depois importado novamente" 
	lRet := .F.
Endif
If  nOpcaImp == 8 .AND. &(cAlias+"->"+cAlias+"_NIV550") == '8'   //Tipo 8
	Aviso("O processamento n�o pode ser realizado",STR0057+"8"+STR0058,{"Fechar"})//"Item j� importado como tipo ###", caso queira importar o mesmo dedever� ser excluido e depois importado novamente" 
	lRet := .F.
Endif    

Return lRet

/*/{Protheus.doc} PLSLSC500
F3 da listagem das criticas do ptu 550
@author PLS Team
@since 08.11.2018
@version P12
/*/
Function PLSP550CRI(cArqImp,lFloppy,lHard,lNetwork)
LOCAL cSalvo := cArqImp
Default lFloppy := .T.
Default lHard   := .T.
Default lNetwork:= .T.

  cArqImp := cGetFile("*.*","Selecione o Arquivo",0,"SERVIDOR\",.T.,Iif(lFloppy,GETF_LOCALFLOPPY,0) + Iif(lHard,GETF_LOCALHARD,0) + Iif(lNetwork,GETF_NETWORKDRIVE,0))

If Empty(cArqImp)
	cArqImp := cSalvo
Endif
	
Return (!Empty(cArqImp))
