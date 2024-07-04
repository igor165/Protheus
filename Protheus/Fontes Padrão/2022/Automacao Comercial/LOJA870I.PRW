#INCLUDE "Protheus.ch"
#INCLUDE "TopConn.ch"
#INCLUDE "LOJA870I.ch"

Static nTotReg 	:= 0  // totalizador de registros
Static cAliasTrb:= '' // totalizador de registros
Static nRecno   := 0  // Recno da tabela mfi
//-------------------------------------------------------------------
/*/{Protheus.doc} LOJA870I
Rotina de ajuste de registros recusados pela administradora financeira.

@author Varejo
@since 28/05/2013
@version P11
/*/
//-------------------------------------------------------------------
Function LOJA870I(cLote,cFiltro) 

Local aArea		:= GetArea()           //Armazena posicao atual da tabela
Local cPerg 	:= PadR("LOJA870I",10) // Grupo de pergunta no SX1
Local cAliasTemp:= GetNextAlias()       // Proximo alias valido
Local lRet  	:= .F.    		
Local lPerg:= .T.  

Default cLote   := ''
Default cFiltro := 'GE'

If !Empty(cLote)
	lPerg:= .F.
EndIf

If Pergunte(cPerg,lPerg) .OR. !Empty(cLote) 
	MsgRun(STR0001,, {|| lRet:= Lj870IFil(cAliasTemp,cLote) })	 //"Aguarde, consultando registros"
	If lRet
		Lj870IGetD(cAliasTemp,cFiltro,cLote)
	Else
		MsgInfo(STR0002,STR0003)	//"Lote nao contem erros ou nao foi executada a rotina de Retorno Arquivo texto."##"Atenção"
	EndIf
	
EndIf


Return
          

//-------------------------------------------------------------------
/*/{Protheus.doc} Lj870IFil
Consulta os dados para exibicao na tela
@author Varejo
@since 28/05/2013
@version P11
/*/
//------------------------------------------------------------------- 
Static Function Lj870IFil(cAliasTemp,cLote)           

Local cQuery := ''                        
Local lRet   := .T.                      

If Empty(cLote)
	cLote:= MV_PAR01
EndIf
cQuery+= " SELECT MFI.*,MFI.R_E_C_N_O_ MFI_MFIREC FROM "+RetSqlName("MFI")+" MFI"+CRLF
cQuery+= " WHERE"+CRLF 
cQuery+= "     MFI.MFI_NUMLOT = '"+cLote+"' "  +CRLF
cQuery+= " AND MFI.MFI_FILIAL = '"+xFilial("MFI")+"' "+CRLF
cQuery+= " AND MFI.MFI_SITGAR IN ('03','07')"+CRLF
cQuery+= " AND MFI.MFI_GARANT = '"+Space(TamSx3("MFI_GARANT")[1])+"' " +CRLF
cQuery+= " AND MFI.D_E_L_E_T_ <> '*'"+CRLF
cQuery+= " ORDER BY MFI.MFI_FILORI, MFI.MFI_NUM, MFI.MFI_ITEM"+CRLF

cQuery:= ChangeQuery(cQuery) 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Realiza a query³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Select(cAliasTemp) > 0
	(cAliasTemp)->(dbCloseArea())
EndIf
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasTemp, .F., .T.)  

TcSetField(cAliasTemp,"MFI_EMISSA","D",8,0)
TcSetField(cAliasTemp,"MFI_DTVIGE","D",8,0)
TcSetField(cAliasTemp,"MFI_FIMVIG","D",8,0)
TcSetField(cAliasTemp,"MFI_DTLOTE","D",8,0)

If (cAliasTemp)->(EOF())
	lRet:= .F.
EndIf

Return lRet 


 
//-------------------------------------------------------------------
/*/{Protheus.doc} Lj870IGetD

@author Varejo
@since 28/05/2013
@version P11
/*/
//-------------------------------------------------------------------  
Static Function Lj870IGetD(cAliasTemp,cFiltro,cLote)

Local cCadastro := STR0004//"Ajuste Arquivo Adm. Financeira"
Local aSize     := MsAdvSize()
Local nOpcA     := GD_UPDATE  
Local nFreeze	:= 0
Local nMax		:= 999999999
Local cLinOk	:= "AllwaysTrue"
Local cTudoOk	:= "AllwaysTrue"
Local cIniCpos	:= ""
Local cFieldOk	:= "AllwaysTrue"
Local cSuperDel	:= ""
Local cDelOk	:= "AllwaysTrue"
Local nCntFor   := 0
Local aAlter    := {"MFI_VALALT","MFI_CUSTO","MFI_CODINT","MFI_FIMVIG","MFI_DIAGAR","MFI_DTVIGE"}
Local lGrava    := .F.

Local aHeader := {}
Local aCols   := {}
Local aGets   := {}
Local aTela   := {}
Local oDlg    := Nil
Local oGetD   := Nil

If cFiltro == "SF"
	aAlter    := {"MFI_VALALT","MFI_CUSTO","MFI_FIMVIG","MFI_DTVIGE"}
EndIF
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta aHeader para GetDados³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aHeader:= {}
dbSelectArea("SX3")
dbSetOrder(1)
If dbSeek("MFI")
	While !Eof() .AND. SX3->X3_ARQUIVO == "MFI"
		AAdd(aHeader,	{AllTrim(X3Titulo()),;
						SX3->X3_CAMPO,;
						SX3->X3_PICTURE,;
						SX3->X3_TAMANHO,;
						SX3->X3_DECIMAL,;
						SX3->X3_VALID,;
						SX3->X3_USADO,;
						SX3->X3_TIPO,;
						SX3->X3_F3,;
						SX3->X3_CONTEXT})
		SX3->(dbSkip())
	EndDo	
EndIf                  
             
AADD( aHeader, { "Recno","MFI_MFIREC", "", 09, 0,,, "N", "", "V"} )

While (cAliasTemp)->(!Eof())		
	Aadd(aCols,Array(Len(aHeader)+1))
	aCols[Len(aCols)][Len(aHeader)+1] := .F.
	For nCntFor := 1 To Len(aHeader)
		If ( aHeader[nCntFor][10] != "V" )
			aCols[Len(aCols)][nCntFor] := &((cAliasTemp)+"->"+aHeader[nCntFor][2]) 
		Else
			If aHeader[nCntFor,2] == "MFI_MFIREC"			
				aCols[Len(aCols)][nCntFor] := (cAliasTemp)->MFI_MFIREC
			Else	
				aCols[Len(aCols)][nCntFor] := CriaVar(aHeader[nCntFor,2])
			EndIf	
		EndIf
	Next
	(cAliasTemp)->(dbSkip())
Enddo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao da tela principal³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 To aSize[6],aSize[5] OF oMainWnd PIXEL 
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Criacao da GetDados ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oGetD := MsNewGetDados():New(000,000,000,000,nOpcA,cLinOk,cTudoOk,cIniCpos,aAlter,;
						  	nFreeze,nMax,cFieldOk,cSuperDel,cDelOk,oDlg,@aHeader,@aCols)
	oGetD:oBrowse:Align:= CONTROL_ALIGN_ALLCLIENT
	oGetD:Refresh()	

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| lGrava:= .T. , oDlg:End()},{||oDlg:End()})

If  lGrava
	//Grava os registros alterados
	Begin Transaction
	Lj870Grv(oGetD)
	End Transaction	
	//Funcao para criacao do arquivo texto
	Lj870IArq(oGetD,cFiltro,cLote)
	
EndIf


Return()


//-------------------------------------------------------------------
/*/{Protheus.doc} Lj870Grv
Efetua a gravacao dos registros alterados
@author Varejo
@since 28/05/2013
@version P11
/*/
//-------------------------------------------------------------------      
Static Function Lj870Grv(oGetD)       
 
Local nX	 :=1
Local nY	 :=1
Local aHeader:= oGetD:aHeader
Local aCols  := oGetD:aCols
Local nPosRec:= aScan(aHeader, {|x| Upper(AllTrim(x[2])) == "MFI_MFIREC"})                

For nX := 1 To Len(aCols)      
	DbSelectArea("MFI")
	DbGoTo(aCols[nX][nPosRec])
	RecLock("MFI",.F.)
	For nY := 1 to Len(aHeader)
		If aHeader[nY][10] <> "V" .AND. aHeader[nY][02] <> "MFI_MFIREC"
			MFI->(FieldPut(FieldPos(aHeader[nY][2]),aCols[nX][nY]))
		EndIf
	Next nY
	REPLACE MFI->MFI_VLRITE		WITH MFI->MFI_VALALT
	MsUnLock()
Next nX
Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} Lj870IArq
Efetua a gravacao dos registros alterados
@author Varejo
@since 28/05/2013
@version P11
/*/
//-------------------------------------------------------------------      
Static Function Lj870IArq(oGetD,cFiltro,cLote)

Local aArea		:= GetArea()
Local cArquivo	:= ''
Local cExtensao := STR0005//"txt" 
Local cTipoArq 	:= STR0006//"Todos os Arquivos (*.*)     | *.* |"
Local cDir      := '' //'C:\'
Local cPath     := '' 
Local cNome     := '' 
Local oDlg		:= Nil
Local cCodSF	:= ""
Local oCodSF	:= Nil

If Empty(cLote)
	cLote:= MV_PAR01
EndIf		
//+-----------------------------------+ 
//| Montagem da tela de processamento.| 
//+-----------------------------------+ 
	 
DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0007) ;  //"Geração de arquivo texto"
FROM 000,000 TO 200,400 PIXEL 
		 
@ 005,005 TO 095,195 OF oDlg PIXEL 
@ 010,020 Say STR0008 OF oDlg PIXEL //" Este programa ira gerar um aquivo TXT, para exportação"
@ 018,020 Say STR0009 OF oDlg PIXEL  //" de informações conforme cofigurado no cadastro de linhas."

If cFiltro == "SF"
	cCodSF	:= Space(TamSx3("MG8_CODIGO")[1])
	//TGet():New(35,008,bSetGet(cArquivo),oDlg,150,010,,,,,,,,.T.,,,,,,,.T.)
	@ 035,008 SAY STR0019	OF oDlg PIXEL SIZE 220,007 //"Cod. Serviço:"			
	@ 033,060 MSGET oCodSF VAR cCodSF Size 60,10 Picture "@!" F3 "MG8"  OF oDlg ;
		VALID( IIf(Empty(cCodSF),Alert(STR0020),NIL) ) PIXEL //"Preencha o Codigo do Serviço!"
EndIF		

TBtnBmp2():New(100,320,026,026,"SDUOPEN",,,,{|| cPath := cGetFile(cTipoArq,STR0010,0,;//"Selecione o diretório de destino"
												cDir,.T.,GETF_LOCALFLOPPY+GETF_NETWORKDRIVE+GETF_LOCALHARD+GETF_RETDIRECTORY, .F.),;
												cDir := Iif(Empty(cPath), cDir, cPath), cArquivo := PadR(cDir + ALLTRIM(cLote)+"."+AllTrim(cExtensao), 250)},;
												oDlg,STR0011)
TGet():New(50,008,bSetGet(cArquivo),oDlg,150,010,,,,,,,,.T.,,,,,,,.T.)
		
DEFINE SBUTTON FROM 070, 030 TYPE 1 ;
ACTION ( Iif(Empty(cArquivo),Alert(STR0012),;
	(IIf( cFiltro <> 'SF',GerArq(cArquivo,oGetD,cFiltro,cLote), ;
	IIf( Empty(cCodSF),Alert(STR0020),LJ870ASF(cArquivo,cFiltro,Nil,cLote,cCodSF) )), ;
	oDlg:End()) ) ) ;
	ENABLE OF oDlg  //"Informe o diretório !"
		 
DEFINE SBUTTON FROM 070, 070 TYPE 2 ; 
ACTION (oDlg:End()) ENABLE OF oDlg 
			
ACTIVATE DIALOG oDlg CENTERED 


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Zerar todas as variaveis staticas³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nTotReg  := 0
cAliasTrb:= ''
nRecno   := 0

RestArea(aArea)
Return()   

//-------------------------------------------------------------------
/*/{Protheus.doc} GerArq
Gera arquivo texto.
@author Varejo
@since 28/05/2013
@version P11
@param cArquivo - diretorio para criacao do arquivo
/*/
//------------------------------------------------------------------- 
Static Function GerArq(cArquivo,oGetD,cFiltro,cLote)

Local cCampoTrb := ''
Local aRegistro := {} // array bidimencional.
Local aCabecalho:= {} // array bidimencional.
Local aRodape   := {} // array bidimencional.
Local nHdl      := 0  
Local nX        := 1
Local nScan     := 0
Local lRet      := .T.
Local aHeader:= oGetD:aHeader
Local aCols  := oGetD:aCols
Local nPosAdmin:= aScan(aHeader, {|x| Upper(AllTrim(x[2])) == "MFI_ADMIN"})
Local cDelimit := '' //caracter delimitador do arquivo                   

If Empty(cLote)
	cLote:= MV_PAR01
EndIf

//Cria o arquivo txt.
If File(cArquivo)
	Ferase(cArquivo)
EndIf 

nHdl:= fCreate(cArquivo)
	
dbSelectArea("SAE")
dbGoTop()
dbSetOrder(1)
If dbSeek(xFilial("SAE")+aCols[01][nPosAdmin],.T.)
   	// Verifica se a Adm.Financeira esta vinculado a um layout
	MFG->(DbSetOrder(1))
	If MFG->(DbSeek(xFilial("MFG")+ SAE->AE_LAYOUT))
		//Verifica se o layout esta vinculado a um bloco
		MFF->(DbSetOrder(1))		 
		If MFF->(DbSeek(xFilial("MFF")+ MFG->MFG_CODBLO ))
			//Verifica se o cabecalho, registro e rodape que foram vinculados ao bloco
			// Cabecalho
			MFE->(DbSetOrder(1))
			MFE->(DbSeek(xFilial("MFE")+ MFF->MFF_CABECA,.T. ))
			While MFE->(!EOF()) .AND. MFE->MFE_CODIGO == MFF->MFF_CABECA
				If !EMPTY(MFE->MFE_ALIAS)
					aadd(aCabecalho, {.T. ,MFE->MFE_ALIAS+"."+MFE->MFE_CAMPO,Alltrim(MFE->MFE_FORMUL),,MFE->MFE_COLINI,MFE->MFE_COLFIN} )
				Else	
					aadd(aCabecalho, {.F. ,MFE->MFE_CAMPO,Alltrim(MFE->MFE_FORMUL),MFE->MFE_COLINI,MFE->MFE_COLFIN} )
				EndIf	
				MFE->(DbSkip())			
			EndDo  
			
			For nX:= 1 To Len(aCabecalho)
			//Monta os campos do select na variavel
				If aCabecalho[nX][1]	
					cCampoTrb+= aCabecalho[nX][2]+","	 						
					aCabecalho[nX][2]:= SubStr(aCabecalho[nX][2],5,TamSx3("MFE_CAMPO")[1])
				EndIf
			Next nX	
							
			// Registro
			MFE->(DbSetOrder(1))
			MFE->(DbSeek(xFilial("MFE")+ MFF->MFF_REGIST,.T. ))			
			While MFE->(!EOF()) .AND. MFE->MFE_CODIGO == MFF->MFF_REGIST
				cDelimit:= MFE->MFE_CARACT
				If !EMPTY(MFE->MFE_ALIAS)
					aadd(aRegistro, {.T. ,MFE->MFE_CAMPO,Alltrim(MFE->MFE_FORMUL),MFE->MFE_COLINI,MFE->MFE_COLFIN,MFE->MFE_CHAVE} )
				Else	
					aadd(aRegistro, {.F. ,MFE->MFE_CAMPO,Alltrim(MFE->MFE_FORMUL),MFE->MFE_COLINI,MFE->MFE_COLFIN,MFE->MFE_CHAVE} )
				EndIf	
				MFE->(DbSkip())			
			EndDo	 
			
			For nX:= 1 To Len(aRegistro)
			//Monta os campos do select na variavel
				If aRegistro[nX][1] .AND. !aRegistro[nX][2] $ cCampoTrb	
					cCampoTrb+= aRegistro[nX][2]+","	 						
					aRegistro[nX][2]:= SubStr(aRegistro[nX][2],5,TamSx3("MFE_CAMPO")[1])
				EndIf
			Next nX	
								
			// Rodape
			MFE->(DbSetOrder(1))
			MFE->(DbSeek(xFilial("MFE")+ MFF->MFF_RODAPE,.T. ))			
			While MFE->(!EOF()) .AND. MFE->MFE_CODIGO == MFF->MFF_RODAPE
				If !EMPTY(MFE->MFE_ALIAS)
					aadd(aRodape, {.T. ,MFE->MFE_ALIAS+"."+MFE->MFE_CAMPO,Alltrim(MFE->MFE_FORMUL),MFE->MFE_COLINI,MFE->MFE_COLFIN} )
				Else	
					aadd(aRodape, {.F. ,MFE->MFE_CAMPO,Alltrim(MFE->MFE_FORMUL),MFE->MFE_COLINI,MFE->MFE_COLFIN} )
				EndIf	
				MFE->(DbSkip())			
			EndDo  

			For nX:= 1 To Len(aRodape)
				//Monta os campos do select na variavel
				If aRodape[nX][1] .AND. !aRodape[nX][2] $ cCampoTrb	
					cCampoTrb+= aRodape[nX][2]+","	 						
					aRodape[nX][2]:= SubStr(aRodape[nX][2],5,TamSx3("MFE_CAMPO")[1])
				EndIf
			Next nX								

			cAliasTrb:= GetNextAlias()
			//Efetua a consulta no banco de dados de acordo com os campos obtidos no cadastro de linhas
			MsgRun( STR0013 ,, { || FilTxt(cAliasTrb,cCampoTrb,cFiltro,cLote) })//"Aguarde, consultando dados ..."
			If (cAliasTrb)->(!EOF())
				Processa({|| lRet:= Lj870Txt(cArquivo ,aRegistro,aCabecalho,aRodape,;
											  cAliasTrb,@nHdl    ,cLote  ,.T.,;
											  cDelimit,cFiltro) },STR0014)// "Gerando arquivo texto..."

			Else
				MsgInfo(STR0015,STR0003)//"Não a dados, verifique os parâmetros"##"Atenção"
				lRet:= .F.

			EndIf
			(cAliasTrb)->(DbCloseArea())		
		EndIf
	
	
	EndIf
	
	cCampoTrb:= ''
	cAliasTrb:= ''
	aRegistro:={}
		
EndIf  

If lRet
	MsgInfo(STR0016,STR0003)//"Arquivo texto gerado com sucesso!"##"Atencao"
EndIf

//Fecha arquivo
If nHdl>0
	fClose(nHdl)
EndIf	

Return()
//-------------------------------------------------------------------
/*/{Protheus.doc} FilTxt
Efetua a extracao de dados para gerar o arquivo texto.
@author Varejo
@since 28/05/2013
@version P11
@param cAliasTrb - Alias para tabela temporaria
       cCampoTrb - Campos do select
/*/
//------------------------------------------------------------------- 
Static Function FilTxt(cAliasTrb,cCampoTrb,cFiltro,cLote)

Local cQuery   := ''

DEFAULT cCampoTrb:= ''   

cQuery+= " SELECT "+cCampoTrb+"MFI_CODIGO,MFI_PRODUT,MFI_DESCRI,MFI_VLRITE,MFI.MFI_GARANT,MFI.R_E_C_N_O_ AS RECNOMFI FROM "+RetSqlName("MFI")+" MFI"+CRLF
// -- CABECALHO ORCAMENTO
cQuery+= " INNER JOIN "+RetSqlName("SL1")+" SL1"+CRLF
cQuery+= " ON SL1.L1_FILIAL = MFI.MFI_FILORI "+CRLF
cQuery+= " AND SL1.L1_NUM = MFI.MFI_NUM "+CRLF
cQuery+= " AND SL1.D_E_L_E_T_ <> '*' "+CRLF
// -- ITENS ORCAMENTO
cQuery+= " INNER JOIN "+RetSqlName("SL2")+" SL2"+CRLF
cQuery+= " ON SL2.L2_FILIAL = MFI.MFI_FILORI "+CRLF
cQuery+= " AND SL2.L2_NUM = MFI.MFI_NUM "+CRLF
cQuery+= " AND SL2.L2_PRODUTO = MFI.MFI_PRODUT "+CRLF
cQuery+= " AND SL2.L2_ITEM = MFI.MFI_ITEM "+CRLF
cQuery+= " AND SL2.D_E_L_E_T_ <> '*' "+CRLF

// -- CABECALHO ORCAMENTO
cQuery+= " LEFT JOIN "+RetSqlName("SL4")+" SL4"+CRLF
cQuery+= " ON SL4.L4_FILIAL = MFI.MFI_FILORI "+CRLF
cQuery+= " AND SL4.L4_NUM = MFI.MFI_NUM "+CRLF
cQuery+= " AND SL4.L4_ITEM = MFI.MFI_ITEM "+CRLF
cQuery+= " AND SL1.D_E_L_E_T_ <> '*' "+CRLF
// -- CLIENTE 
cQuery+= " INNER JOIN "+RetSqlName("SA1")+" SA1"+CRLF
cQuery+= " ON SA1.A1_FILIAL = '"+xFilial("SA1")+"' "+CRLF
cQuery+= " AND SA1.A1_COD  = SL1.L1_CLIENTE "+CRLF
cQuery+= " AND SA1.A1_LOJA = SL1.L1_LOJA "+CRLF
cQuery+= " AND SA1.D_E_L_E_T_  <> '*' "+CRLF
// -- PRODUTOS
cQuery+= " INNER JOIN "+RetSqlName("SB1")+" SB1"+CRLF
cQuery+= " ON SB1.B1_FILIAL = '"+xFilial("SB1")+"' "+CRLF
cQuery+= " AND SB1.B1_COD = MFI.MFI_PRODUT"+CRLF
cQuery+= " AND SB1.D_E_L_E_T_ <> '*' "+CRLF
// -- CONDICAO ITENS ORCAMENTO 
cQuery+= " WHERE "+CRLF
cQuery+= " MFI.MFI_FILIAL = '"+xFilial("MFI")+"' "+CRLF
cQuery+= " AND MFI.MFI_NUMLOT = '"+cLote+"' "+CRLF
cQuery+= " AND MFI_SITGAR IN ('03','07') 
cQuery+= " AND MFI_ORIGEM = '"+cFiltro+"' "
cQuery+= " AND MFI.D_E_L_E_T_ <> '*' "+CRLF
 
cQuery:= ChangeQuery(cQuery) 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Realiza a query³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Select(cAliasTrb) > 0
	(cAliasTrb)->(dbCloseArea())
EndIf
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasTrb, .F., .T.)
 
Return() 

