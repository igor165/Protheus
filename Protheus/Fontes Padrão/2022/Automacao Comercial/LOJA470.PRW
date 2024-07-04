#INCLUDE "PROTHEUS.CH"
#INCLUDE "LOJA470.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡…o    ³Lj470Arq    ³ Autor ³ Vendas Clientes     ³ Data ³06/09/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Apresenta os arquivos de NF de transferencia por Meio Mag. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Lj470Arq                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGALOJA/FRONTLOJA                                         ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LOJA470()
Local oDlgArq
Local oArq
Local oSim                            
Local oNao  
Local lLJ470FILE 		:= ExistBlock("LJ470FILE")      
Local cDirGrv   		:= ""  	// Diretorio onde serao armazenados os arquivos magneticos
Local cFile				:= ""
Local lRet				:= .T.
Local xRet                                                  // Retorno do PE LJ470FILE
Local aArq              := {}                              // Arquivos de Nota Fiscais de Transferencia meio Magnetico 

Private oDlg
Private lAllAcesso	:= .F.

If ExistFunc("Lj430VlDir")
	cDirGrv   	:= Lj430VlDir()
Else
	cDirGrv   	:= SuperGetMV("MV_LJDIRGR",,"")
EndIf

//³Release 11.5 - SmartClient HTML³
If ExistFunc("LjChkHtml")
	If LjChkHtml ()
		FwAvisoHtml()
		lRet := .F.
	EndIf
EndIf	

If lRet
	If Empty(cDirGrv)
		cDirGrv := GetClientDir()
	EndIf
	                
	If Substr(cDirGrv,Len(cDirGrv), 1) <> "\"
		cDirGrv := cDirGrv + "\"
	EndIf
	
	cFile := cDirGrv + '*.NFT'
	
	If lLJ470FILE
		LjGrvLog( Nil, " Chamada do P.E. LJ470FILE")
	    xRet  := ExecBlock("LJ470FILE",.F.,.F.)
	    LjGrvLog( Nil, " Retorno do P.E. LJ470FILE", xRet)
	    If ValType(xRet) == "C"    
		   cFile := cDirGrv + xRet
		ElseIf ValType(xRet) == "A"
		   aArq := AClone(xRet)
		Endif
	EndIf
	
	If Len(aArq) == 0
	   aArq := Directory(cFile)	
	Endif   
		
	If Len(aArq) == 0
	   MsgInfo(STR0001 + cFile) //Não foi encontrado arquivos de Nota Fiscais de Transferencia meio Magnetico 
	   lRet := .F.
	EndIf   
	
	If lRet 
	
		AEval(aArq,{|X| X[5]:='N'})
		
		DEFINE MSDIALOG oDlgArq TITLE STR0002 FROM 0,0 TO 220,450 OF oDlg PIXEL //"Arquivos de Nota Fiscais de Transferencia meio Magnetico"
		
		oSim   := LoadBitmap(GetResources(), "LBOK")
		oNao   := LoadBitmap(GetResources(), "LBNO")
		
		@05,10 LISTBOX oArq FIELDS HEADER "",STR0003,STR0004,STR0005,STR0006 FIELDSIZES 14,55,20,15 SIZE 205,60 PIXEL //Nome/Tam/Data/Hora
		oArq:SetArray(aArq)
		oArq:bLine := {|| {If(aArq[oArq:nAt,5]=="S",oSim,oNao),aArq[oArq:nAt,1],aArq[oArq:nAt,2],aArq[oArq:nAt,3],aArq[oArq:nAt,4]}}
		oArq:bLDblClick := {|| aArq[oArq:nAt,5]:=If(aArq[oArq:nAt,5]=="S","N","S"),;
								  oArq:DrawSelect(),;
								  lAllAcesso:=.T.,;
								  AEval(aArq, {|aLinha| lAllAcesso:=If(lAllAcesso.AND.aLinha[5]=="S",.T.,.F.)}),;
								  oAllAcesso:Refresh()}
								  
		@ 70, 10 SAY STR0026  SIZE 200,10 OF oDlgArq PIXEL COLOR CLR_HRED //"Composição do nome do arquivo: Filial Orig. + Loja Dest. + Num. NF"
		
		 @95,10 CHECKBOX oAllAcesso VAR lAllAcesso PROMPT STR0007 SIZE 80, 09 PIXEL ; //Seleciona todos
		ON CLICK  (MarkAll(lAllAcesso,@aArq ),oArq:Refresh()) 
		
		DEFINE SBUTTON FROM	93,153 TYPE 1 ENABLE OF oDlgArq ACTION (Lj470Rec(aArq),oDlgArq:End())
		DEFINE SBUTTON FROM 93,190 TYPE 2 ENABLE OF oDlgArq ACTION oDlgArq:End()
		
		ACTIVATE DIALOG oDlgArq CENTERED
	
	EndIf
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡…o    ³ MarkAll    ³ Autor ³ Vendas Clientes     ³ Data ³17/07/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Marca e desmarca todos as permissoes                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MarkAll(lAll,aAcesso)                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ lAll  - Flag de status do CHECKBOX                         ³±±
±±³          ³ aAcesso  - Array dos acessos                               ³±±
±±³          ³            aAcesso[1,1] - Flag de Permisao                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGALOJA/FRONTLOJA                                         ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MarkAll(lAll, aArq)
Local nX               // Controle de loop

For nX := 1 To Len(aArq)
  aArq[nX][5] := If(lAll,"S","N")
Next nX

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡…o    ³Lj470Rec    ³ Autor ³ Vendas Clientes     ³ Data ³17/07/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Processa a nota fiscal de entrada                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Lj470Rec(aArq)                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 - Array de notas                                     ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Lj470Rec(aArq)
Local aCab          := {}
Local aItens        := {}
Local aFieldsSF2	:= {}
Local aFieldsSD2	:= {}
Local aDadosSD2		:= {}
Local aTotItens		:= {}
Local aLj470Rec     := {}
Local aArea         := GetArea()
Local aAreaSA2		:= {}
Local aFornec		:= {}
Local aLJ470CAB		:= {}
Local aLJ470ITE		:= {}

Local nA            := 0
Local nX            := 0
Local nY            := 0
Local nPos          := 0
Local nPointer      := 0
Local nCount        := 0
Local nPosForCod	:= 0								//Posicao do codigo do fornecedor dentro do array aCab
Local nPosForLoja	:= 0								//Posicao da loja do fornecedor dentro do array aCab
Local nTamF1Cod		:= TamSX3( "A2_COD" )[1]			//Tamanho do campo A2_COD
Local nTotalFiles	:= 0

Local cItem         := ""
Local cLjCDDis      := ""
Local cLjLODis      := ""
Local cTesEnt       := ""								//TES da NF de entrada
Local cCFOP         := ""								//Codigo fiscal de operacao do TES de entrada
Local cFile         := ""
Local cRetCF		:= ""								//Retorno do primeiro caracter do CFOP, de acordo com a regra
Local cMsgErro		:= ""

Local lRet          := .T.
Local lLJ470ACT 	:= ExistBlock("LJ470ACT")
Local lLJ470REC 	:= ExistBlock("LJ470REC")
Local lLJ470CAB 	:= ExistBlock("LJ470CAB")
Local lLJ470ITE		:= ExistBlock("LJ470ITE")
Local lRastro		:= .F.
Local lItem			:= .F.								//Verifica se existe item a ser importado do arquivo

Local cMvEstado		:= SuperGetMv("MV_ESTADO")			//Verifica qual estado setado no parametro
Local cRestoCfo		:= ""								//Conteudo do restante do codigo do CFOP
Local cDirGrv   	:= ""  	// Diretorio onde serao armazenados os arquivos magneticos
//³Variaveis utilizadas para verificar se os dados do arquivo ja foi importado³
Local cDoc			:= ""  								//Nro do documento de entrada
Local cSerie		:= ""								//Serie do documento
Local cFormul		:= ""								//Utiliza formulario proprio (S)im ou (N)ao.
Local cD1Cod		:= ""								//Codigo do produto
Local cD1Item		:= "" 								//Numero do item
Local cMsgProd		:= ""								//Informa os item do arquivo que ja foi gravado no SD1

Private lMsErroAuto:=.F.                          

If ExistFunc("Lj430VlDir")
	cDirGrv   	:= Lj430VlDir()
Else
	cDirGrv   	:= SuperGetMV("MV_LJDIRGR",,"")
EndIf

If Empty(cDirGrv)
	cDirGrv := GetClientDir()
EndIf
 
If Substr(cDirGrv,Len(cDirGrv), 1) <> "\"
	cDirGrv := cDirGrv + "\"
EndIf

nTotalFiles := Len(aArq)

For nPointer := 1 to nTotalFiles

	If aArq[ nPointer ][5] <> 'S'
		Loop
	EndIf
	
	If lLJ470ACT
		LjGrvLog( Nil, " Chamada do P.E. LJ470ACT")
		aFornec := ExecBlock("LJ470ACT",.F.,.F.,{ ALLTRIM( aArq[ nPointer ][1] ) } )
		LjGrvLog( Nil, " Retorno do P.E. LJ470ACT", aFornec)		
	EndIf
	
	If lLJ470ACT .And. Valtype( aFornec ) == "A" .AND. Len( aFornec ) >= 2
		cLjCDDis := AllTrim(aFornec[1]) 											//Codigo do Fornecedor (distribuidor) origem
		cLjLODis := AllTrim(aFornec[2]) 											//Loja do Fornecedor (distribuidor) origem		
	Else
		cLjCDDis := AllTrim(GetNewPar("MV_LJCDDIS","000001")) 		//Codigo do Fornecedor (distribuidor) origem
		cLjLODis := AllTrim(GetNewPar("MV_LJLODIS","01"))     						//Loja do Fornecedor (distribuidor) origem
	EndIf	

	cLjCDDis := Padr(cLjCDDis,nTamF1Cod) 		//Codigo do Fornecedor (distribuidor) origem
	cLjLODis := Padr(cLjLODis,TamSx3("A2_LOJA")[1])//Loja do Fornecedor (distribuidor) origem
	
	LjGrvLog( Nil, " Dados do Fornecedor - [Código e Loja]" , {cLjCDDis,cLjLODis})
	
	/*Validação da existência do Fornecedor*/
	DbSelectArea("SA2")
	aAreaSA2 := SA2->(GetArea())
	SA2->(DbSetOrder(1)) //A2_FILIAL + A2_COD + A2_LOJA 
	If !SA2->(DbSeek(xFilial("SA2")+cLjCDDis+cLjLODis))
		LjGrvLog( Nil, " Fornecedor não encontrado (tabela SA2) - "+;
				" Isso afeta diretamente no processo dessa rotina:" +;
				" Causando inconsistência na tabela Entradas(SD1)"+ CHR(10)+CHR(13)+;
				" Verifique: " + CHR(10)+CHR(13)+;
				"1 - Parâmetros: MV_LJCDDIS e MV_LJLODIS"+ CHR(10)+CHR(13)+;
				"2 - Se estiver compilado o PE LJ470ACT, verifique seu retorno")
	EndIf
	
	//³Zera as variaveis	
	aFieldsSF2 := {}
	aFieldsSD2 := {}
	aDadosSD2  := {}
	aTotItens  := {}
    
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Faz a leitura do arquivo texto              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cFile := ALLTRIM( aArq[ nPointer ][1] )
	LjMsgRun(STR0008 + cFile,,{|| lRet := Lj470Le(cFile,@aFieldsSF2,@aFieldsSD2,@aDadosSD2)}) //Aguarde...Lendo arquivo Meio magnético -
	If !lRet
		Return .F.
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ponde de entrada para alterar os dados do arquivo de nota recebido  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lLJ470REC
		/*Estrutura do Array - aFieldsSF2:   ³
		//³aFieldsSF2[X][1]- Nome do campo    ³
		//³aFieldsSF2[X][2]- Tamanho do campo ³
		//³aFieldsSF2[X][3]- Tipo do campo    ³
		//³aFieldsSF2[X][4]- conteudo do campo³
		//³                                   ³
		//³Estrutura do Array - aFieldsSD2    ³
		//³aFieldsSD2[X][1]- Nome do campo    ³
		//³aFieldsSD2[X][2]- Tamanho do campo ³
		//³aFieldsSD2[X][3]- Tipo do campo    ³
		//³                                   ³
		//³Estrutura do Array - aDadosSD2     ³
		//³aDadosSD2[Item][X]- X - Indice dos ³
		//³campos com seus conteudo.          */
		LjGrvLog( Nil, " Chamada do P.E. LJ470REC")
		aLj470Rec:= ExecBlock("LJ470REC",.F.,.F.,{aFieldsSF2,aFieldsSD2,aDadosSD2})
		LjGrvLog( Nil, " Retorno do P.E. LJ470REC",aLj470Rec)
		If ValType(aLj470Rec) == "A" .And. Len( aLj470rec ) == 3
			aFieldsSF2 := Aclone(aLj470rec[1])
			aFieldsSD2 := Aclone(aLj470rec[2])
			aDadosSD2  := Aclone(aLj470rec[3])
		Else
			LjGrvLog( Nil, " Retorno Inválido do P.E. LJ470REC - Verifique documentação: http://tdn.totvs.com/display/PROT/LJ470REC ")
			Conout(" Retorno Inválido do P.E. LJ470REC - Verifique documentação: http://tdn.totvs.com/display/PROT/LJ470REC ")
		EndIf
	Endif
	
	If cPaisLoc == "BRA"
		aCab := { ;
		{"F1_TIPO"      ,NIL  ,NIL},;
		{"F1_FORMUL"    ,'N'  ,NIL},;
		{"F1_DOC"       ,NIL  ,NIL},;
		{"F1_SERIE"     ,NIL  ,NIL},;
		{"F1_EMISSAO"   ,NIL  ,NIL},;
		{"F1_FORNECE"   ,NIL  ,NIL},;
		{"F1_LOJA"      ,NIL  ,NIL},;
		{"F1_FRETE"     ,NIL  ,NIL},;
		{"F1_BASEICM"   ,NIL  ,NIL},;
		{"F1_VALICM"    ,NIL  ,NIL},;
		{"F1_BASEIPI"   ,NIL  ,NIL},;
		{"F1_VALIPI"    ,NIL  ,NIL},;
		{"F1_VALBRUT"   ,NIL  ,NIL},;
		{"F1_BRICMS"    ,NIL  ,NIL},;
		{"F1_ICMSRET"   ,NIL  ,NIL},;
		{"F1_COND"      ,NIL  ,NIL},;
		{"F1_ESPECIE"   ,'NFE',NIL}}
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Inicializa as variaveis  da identificacao do documento..³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cDoc	:= "" 
		cSerie	:= ""
		cFormul	:= ""
		
		If lLJ470CAB
			LjGrvLog( Nil, " Chamada do P.E. LJ470CAB")
			aLJ470CAB := ExecBlock("LJ470CAB",.F.,.F.,{aCab})
			LjGrvLog( Nil, " Retorno do P.E. LJ470CAB",aLJ470CAB)
			
			If	ValType(aLJ470CAB) == "A" .And. Len(aLJ470CAB) > 0
				aCab := aClone(aLJ470CAB)
			Else
				LjGrvLog( Nil, " Retorno do P.E. LJ470CAB inválido. Verifique: http://tdn.totvs.com/pages/viewpage.action?pageId=6790874")
				Conout(" Retorno do P.E. LJ470CAB inválido. Verifique: http://tdn.totvs.com/pages/viewpage.action?pageId=6790874 ")
			EndIf			
		EndIf
		
		FOR nCount := 1 TO LEN( aCab )
			If aCab[ nCount ][1] == "F1_FORNECE"
				aCab[ nCount ][2] := cLjCDDis
			ElseIf  aCab[ nCount ][1] == "F1_LOJA"
				aCab[ nCount ][2] := cLjLODis
			Else
				IF ( nPos := ASCAN( aFieldsSF2, { |X| ALLTRIM( SUBSTR( X[1], 3 ) ) == ALLTRIM( SUBSTR( aCab[ nCount ][1], 3 ) ) } ) ) > 0
					aCab[ nCount ][2] := aFieldsSF2[ nPos ][4]
				EndIf
			EndIf
			
			/*Armazena os dados da nota para fazer a busca*/
			If aCab[ nCount ][1] == "F1_DOC"
				cDoc := aCab[ nCount ][2]
			ElseIf aCab[ nCount ][1] == "F1_SERIE"
				cSerie:= aCab[ nCount ][2]		
			ElseIf aCab[ nCount ][1] == "F1_FORMUL"
				cFormul:= aCab[ nCount ][2]
			EndIf
		Next nCount
		
		/*Inicializa as variaveis  do Item do Pedido*/
		cItem		:= "01"    
		cD1Cod 		:= ""
		cD1Item		:= ""
		cMsgProd	:= ""
		lItem		:= .F.
		
		For nY:=1 to Len(aDadosSD2)
			If( nPos := ASCAN(aFieldsSD2,{|X| alltrim(subs(X[1],3))=='_COD'}) ) > 0
				lRastro := Rastro(aDadosSD2[nY,nPos])
			EndIf
	
			If lRastro
		 		aItens:={;
		 		{"D1_COD"    ,NIL,NIL},;
				{"D1_ITEM"   ,NIL,NIL},;
				{"D1_UM"     ,NIL,NIL},;
				{"D1_QUANT"  ,NIL,NIL},;
				{"D1_VUNIT"  ,NIL,NIL},;
				{"D1_TOTAL"  ,NIL,NIL},;
				{"D1_VALIPI" ,NIL,NIL},;
				{"D1_IPI"    ,NIL,NIL},;
				{"D1_PICM"   ,NIL,NIL},;
				{"D1_VALICM" ,NIL,NIL},;
				{"D1_BASEICM",NIL,NIL},;
				{"D1_BASEIPI",NIL,NIL},;
				{"D1_TES"    ,NIL,NIL},;
				{"D1_CF"     ,NIL,NIL},;
				{"D1_RATEIO" ,'2',NIL},;
				{"D1_LOCAL"  ,NIL,NIL},;
				{"D1_BRICMS" ,NIL,NIL},;
				{"D1_LOCPAD" ,NIL,NIL},;
				{"D1_ICMSRET",NIL,NIL},;
				{"D1_LOTECTL",Nil,Nil},;   	// Inclusao de campos ref. ao lote
				{"D1_NUMLOTE",Nil,Nil},;	// Inclusao de campos ref. ao lote
				{"D1_DTVALID",Nil,Nil},;	// Inclusao de campos ref. ao lote
				{"D1_POTENCI",Nil,Nil}} 	// Inclusao de campos ref. ao lote
			Else
		 		aItens:={;
		 		{"D1_COD"    ,NIL,NIL},;
				{"D1_ITEM"   ,NIL,NIL},;
				{"D1_UM"     ,NIL,NIL},;
				{"D1_QUANT"  ,NIL,NIL},;
				{"D1_VUNIT"  ,NIL,NIL},;
				{"D1_TOTAL"  ,NIL,NIL},;
				{"D1_VALIPI" ,NIL,NIL},;
				{"D1_IPI"    ,NIL,NIL},;
				{"D1_PICM"   ,NIL,NIL},;
				{"D1_VALICM" ,NIL,NIL},;
				{"D1_BASEICM",NIL,NIL},;
				{"D1_BASEIPI",NIL,NIL},;
				{"D1_TES"    ,NIL,NIL},;
				{"D1_CF"     ,NIL,NIL},;
				{"D1_RATEIO" ,'2',NIL},;
				{"D1_LOCAL"  ,NIL,NIL},;
				{"D1_BRICMS" ,NIL,NIL},;
				{"D1_LOCPAD" ,NIL,NIL},;
				{"D1_ICMSRET",NIL,NIL}}
			Endif
			
			If lLJ470ITE
				LjGrvLog( Nil, " Chamada do P.E. LJ470ITE")
				aLJ470ITE := ExecBlock("LJ470ITE",.F.,.F.,{aItens})
				LjGrvLog( Nil, " Retorno do P.E. LJ470ITE",aLJ470ITE)
				
				If ValType(aLJ470ITE) == "A" .And. Len(aLJ470ITE) > 0
					aItens := aClone(aLJ470ITE)
				Else
					LjGrvLog( Nil, " Retorno inválido do P.E. LJ470ITE ")
					Conout(" Retorno inválido do P.E. LJ470ITE ")
				EndIf
			EndIf			                               

			FOR nCount := 1 TO LEN( aItens )
			
				IF ( nPos := ASCAN( aFieldsSD2, { |X| ALLTRIM( SUBSTR( X[1], 3 ) ) == ALLTRIM( SUBSTR( aItens[ nCount ][1], 3 ) ) } ) ) > 0

					/*Verifica se o item  ja foi importado do arquivo
					  corrente para evitar error.log de chave duplicada.*/
					If aItens[ nCount ][1] == "D1_COD"        
						cD1Cod := aDadosSD2[ nY ][ nPos ]
					ElseIf aItens[ nCount ][1] == "D1_ITEM"        
						cD1Item := aDadosSD2[ nY ][ nPos ]
					EndIf
					
					If !Empty( cD1Cod ) .AND. !Empty( cD1Item )
						If SD1->( DbSeek( xFilial("SD1")+cDoc+cSerie+cLjCDDis+cLjLODis	+cD1Cod+cD1Item+cFormul ) )							
							If Empty(cMsgProd)
								cMsgProd := cFile
							EndIf 
							lItem := .F. 
							Exit
						Else
							lItem 		:= .T.    
							cD1Cod 		:= ""
							cD1Item		:= ""
						EndIf						
					EndIf
					
					aItens[ nCount ][2] := aDadosSD2[ nY ][ nPos ]
				Else
					LjGrvLog( Nil, " Campos da tabela SD1 [" + aItens[ nCount ][1] +;
									"] não existe na SD2, portanto não será enviado ")
				EndIf
			Next nCount
			
			If lItem
			
				If( nPos := ASCAN(aFieldsSD2,{|X| alltrim(subs(X[1],3))=='_PRUNIT'}) ) > 0
					aItens[5,2]:=aDadosSD2[nY,nPos]
				EndIf
				IF( nPos := ASCAN(aFieldsSD2,{|X| alltrim(subs(X[1],3))=='_TES'}) ) > 0
					// Sistema ira utilizar o TES de devolucao para entrada do item
					cTes    := aDadosSD2[nY,nPos]
					cTesEnt := ""
					cCFOP   := ""
					DbSelectArea('SF4')
					SF4->(DbSetOrder(1))
					If SF4->(DbSeek(xFilial('SF4')+cTes)) .AND. !Empty(SF4->F4_TESDV)
				       cTesEnt := SF4->F4_TESDV
				    EndIf
				      
				    If Empty(cTesEnt)   
					   cTesEnt := SuperGetMV("MV_TESENT")   
					EndIf
					 
		            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	                //³Busca o codigo fiscal de operacao do TES de entrada³
	                //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If SF4->(DbSeek(xFilial('SF4')+cTesEnt))
					   cCFOP  := SF4->F4_CF
					EndIf   				
				EndIf
				aItens[13,2]:=cTesEnt
				aItens[2,2]:=cItem
	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Calcula CFOP de acordo com o estado do fornecedor³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If SubStr(cCFOP,1,3) == "999" .OR. SubStr(cCFOP,1,3) == "000" .OR. SubStr(cCFOP,1,4) $ "1601#1602#5601#5602"
					aItens[14,2] := cCFOP
				Else
					nPosForCod	:= aScan(aCab,{|x| x[1] == "F1_FORNECE"})
					nPosForLoja := aScan(aCab,{|x| x[1] == "F1_LOJA"})
	
					If nPosForCod > 0 .AND. nPosForLoja > 0
						cRestoCfo := SubStr(cCFOP,2,Len(cCFOP)-1)
	
						SA2->(DbSetOrder(1))
						If SA2->(DbSeek(xFilial("SA2")+aCab[nPosForCod][2]+aCab[nPosForLoja][2]))
							If SA2->A2_EST == "EX" .OR. SA2->A2_TIPO == "X"
								cRetCF := "3"
							Else
								If SA2->A2_EST == cMvEstado
									cRetCF := "1"
								Else
									cRetCF := "2"
								EndIf
							Endif
							cCFOP := cRetCF + cRestoCfo
						Endif
					Endif
				Endif
		
				aItens[14,2]:=cCFOP
				cItem := SomaIt(cItem)
				aadd(aTotItens,aItens)
			Else
				
				Exit
					
			EndIf
			
		Next nY

		/*Faz a importacao do arquivo somente se  nao encontrou                       
		nenhum item da nota ja gravado na base.
		Ex: Por algum motivo o arquivo não foi renomeado. Estava Duplicando os registros*/
		
		lRet := .T.
		
		If Empty( cMsgProd )
			LjGrvLog( Nil, " Antes da Execução da ExecAuto MATA103 - Parâmetros {Cabeçalho , Itens}", {aCab,aTotItens})
			LjMsgRun(STR0009,,{|| MSExecAuto({|x,y,z| MATA103(x,y,z)},aCab,aTotItens,3)})//"Aguarde...Gravando Itens do pedido"
			LjGrvLog( Nil, " Retorno da Execução da ExecAuto MATA103 ")
			
			If lMsErroAuto
				cMsgErro := MostraErro()
				LjGrvLog( Nil, " Erro na execução da ExecAuto MATA103 ", cMsgErro)
				Conout(" Erro na execução da ExecAuto MATA103: " + cMsgErro)
				lRet:=.F.				
			EndIf
		EndIf
				
		If lRet
			/*Ajuste no tamanho do arquivo a ser renomeado, pois antes o sistema considerava ³
			somente os 8 primeiros caracteres do arquivo*/
			//STR0023#"Importação de Arquivo"
			//STR0024#"O arquivo"
			//STR0025#"já foi processado anteriormente e será renomeado."
			If !Empty(cMsgProd)	
				Aviso(STR0023, STR0024 + " " + cMsgProd + " " + STR0025 , {"OK"} )
			Else
				//Pra mostrar a mensagem somente no ultimo arquivo importado e não 
				//atrapalhar o processo de importação do arquivo
				If nTotalFiles == nPointer 
					//STR0027#"Arquivo Importado com Sucesso"
					Aviso(STR0023, STR0027 , {"OK"} )
				EndIf
			EndIf
			
			FRename(cDirGrv+cFile,cDirGrv+Subs(cFile,1,len(cfile)-4) +'.PRC')			
			LjGrvLog( Nil, " Arquivo [" + cDirGrv + cFile + "] processado com Sucesso ")
			Conout(" Arquivo [" + cDirGrv + cFile + "] processado com Sucesso ")			
		EndIf
		
	Else 
		LjMsgRun(STR0014,,{|| lRet := Lj470RemEnt(aFieldsSF2 , aFieldsSD2 , aDadosSD2 , @cLjCDDis , ;
		                                           @cLjLODis  , cFile      , cDirGrv) })  //"Aguarde... Gerando Remito..."
	EndIf
Next nPointer

RestArea(aArea)

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³Lj470Le   ºAutor  ³Vendas Clientes     º Data ³  11/07/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Lj470Le(cFile,aFieldsSF2,aFieldsSD2,aDadosSD2)
Local cNota
Local nHandle
Local cBuffer:=space(30)
Local nX
Local nSize,nLidos,nBaytes
Local cDirGrv   		:= "" 	// Diretorio onde serao armazenados os arquivos magneticos
Local lRet		:= .T.

If ExistFunc("Lj430VlDir")
	cDirGrv   	:= Lj430VlDir()
Else
	cDirGrv   	:= SuperGetMV("MV_LJDIRGR",,"")
EndIf

If Empty(cDirGrv)
	cDirGrv := GetClientDir()
EndIf
                           
If Substr(cDirGrv,Len(cDirGrv), 1) <> "\"
	cDirGrv := cDirGrv + "\"
EndIf

aFieldsSF2 := {}
aFieldsSD2 := {}
aDadosSD2  := {}

if !file( cDirGrv + cFile)
	MsgInfo(STR0010 + cDirGrv + cFile) //"Arquivo de Nota não encontrado "
	lRet := .F.
EndIf

If lRet
	nHandle := fOpen(cDirGrv + cFile)
	If nHandle == -1
		// Ocorreu um ero ao ler o arquivo criptografado.
		MsgStop(STR0011 + cDirGrv + cFile) //Ocorreu um erro ao ler o arquivo de 
		lRet := .F.
	EndIf
EndIf

If lRet
	//Le o arquivo de Nota
	nSize 	:= FSeek( nHandle, 0, 2 )
	FSeek( nHandle, 0 )
	nLidos:=FRead( nHandle, @cBuffer, (78 + TamSx3("F2_DOC")[1]) - 6 )
	//Valida se o qrquivo foi gerado pela rotina LJ430Disk
	If At('DISTRIBUICAO DE MERCADORIA',cBuffer)=0
		MsgInfo(STR0012 + cFile) //Arquivo de Nota Invalido 
		lRet := .F.
	EndIf
EndIf

If lRet

	aFieldsSF2:={}
	//Leitura dos campos ( SF2 )
	While nLidos<=nSize
		cBuffer := Space(14)
		nBaytes:=FRead( nHandle, @cBuffer, Len(cBuffer) )
		if At('#',cBuffer)>0
			FSeek( nHandle, At('#',cBuffer)-Len(cBuffer), 1 )
			exit
		EndIf
		//Gravando no array Nome do campo, tamanho do Campo, tipo do campo
		aadd(aFieldsSF2,{alltrim(subs(cBuffer,1,10)),subs(cBuffer,11,3),subs(cBuffer,14,1),nil})
		nLidos+=nBaytes
	End
	
	for nX:=1 to len(aFieldsSF2)
		cBuffer:=space(10)
		FRead( nHandle, @cBuffer, Val(aFieldsSF2[nX,2]) )
		if aFieldsSF2[nX,3]=='N'
			cBuffer:=Val(cBuffer)
		ElseIf aFieldsSF2[nX,3]=='D'
			cBuffer:=CtoD(Substr(cBuffer,7,2) + "/" + Substr(cBuffer,5,2) + "/" + Substr(cBuffer,1,4))
		EndIf
		aFieldsSF2[nX,4]:=cBuffer
	Next nX                             
                                    
	cBuffer:=space(10)
	nLidos:=FRead( nHandle, @cBuffer, (18 + TamSx3("F2_DOC")[1]) - 6 )
	cNota:=subs(cBuffer,11,TamSx3("F2_DOC")[1])

	//Leitura dos campos ( SD2 )
	While .T.
		cBuffer := Space(14)
		FRead( nHandle, @cBuffer, Len(cBuffer) )
		if At('#',cBuffer)>0
			// Retornando -1 no At, para que esteja posicionado o caracter #, para validadacao das linhas
			FSeek( nHandle, (At('#',cBuffer)-1)-Len(cBuffer), 1 )
			exit
		EndIf
		aadd(aFieldsSD2,{alltrim(subs(cBuffer,1,10)),subs(cBuffer,11,3),subs(cBuffer,14,1)})
	End

	nLidos 	 := FSeek( nHandle, 0, 1 )
	aDadosSD2:={}

	//Leitura dos DADOS ( SD2 )
	While nLidos<nSize
		cBuffer:=space(10)
		nBaytes:=FRead( nHandle, @cBuffer, 1 )
		if cBuffer<>'#'
			MsgInfo(STR0013 + cNota) //Erro de Leitura do arquivo da Nota Fiscal 
	      	lRet := .F.
		Endif
		
		If lRet
			nLidos+=nBaytes
			aadd(aDadosSD2,Array(Len(aFieldsSD2)))
			for nX:=1 to len(aFieldsSD2)
				cBuffer:=space(10)
				nBaytes:=FRead( nHandle, @cBuffer, Val(aFieldsSD2[nX,2]) )
				if aFieldsSD2[nX,3]=='N'
					cBuffer:=Val(cBuffer)
				ElseIf aFieldsSD2[nX,3]=='D'
					cBuffer:=CtoD(Substr(cBuffer,7,2) + "/" + Substr(cBuffer,5,2) + "/" + Substr(cBuffer,1,4))
				EndIf
				aDadosSD2[Len(aDadosSD2),nX]:=cBuffer
				nLidos+=nBaytes
			Next nX
			cBuffer:=space(10)
			nLidos+=FRead( nHandle, @cBuffer, 1 )
		EndIf
	End
	fClose(nHandle)
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³Lj470RemEnt ºAutor  ³Vendas Clientes     º Data ³  04/06/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Descri‡…o ³ Gera Remito de Entrada (Localizacoes).                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ºUso       ³ LOJA470()                                                    º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Lj470RemEnt(aFieldsSF2 , aFieldsSD2 , aDadosSD2 , cLjCDDis , ;
                            cLjLODis   , cFile      , cDirGrv)
Local aCab 	    := {}	
Local aItens    := {}             
Local aTotItens := {}       
Local aAreaSF4  := {}
Local aAreaAtu  := GetArea()
Local lRet      := .T.
Local nX        := 0
Local nY        := 0       
Local nTamDoc   := TamSx3("F1_DOC")[01]
Local cTes      := ""
Local cSerie    := Space(TamSx3("F1_SERIE")[01])
Local cDoc      := Space(nTamDoc)
Local oDlg
Local oSerie
Local oDoc  
Local oLjCDDis     
Local oLjLODis
Local oOk
Local oCanc

//³Release 11.5 - SmartClient HTML³
If ExistFunc("LjChkHtml")
	If LjChkHtml()
		FwAvisoHtml()
		lRet := .F.
	EndIf
EndIf

If lRet

	cLjCDDis := Space(TamSx3("F1_FORNECE")[1])
	cLjLODis := Space(TamSx3("F1_LOJA")[1])
	
	DEFINE MSDIALOG oDlg TITLE STR0015+cFile+")" From 10,30 To 20,63  //"Remito (Arquivo: "
	
	@ 01.5, 01 TO 24.5,130 LABEL STR0016 OF oDlg PIXEL   //"Fornecedor - Loja "
	@ 09, 005 Say  STR0017  SIZE 30,8 OF oDlg PIXEL //"Fornecedor"
	@ 09, 040 MSGET oLjCDDis VAR cLjCDDis F3 "FOR" VALID ExistCpo("SA2",cLjCDDis) Picture PesqPict("SF1","F1_FORNECE") SIZE 35,8 OF oDlg PIXEL 
	@ 09, 080 Say  STR0018 SIZE 15,8 OF oDlg PIXEL  //"Loja"
	@ 09, 102 MSGET oLjLODis VAR cLjLODis VALID ExistCpo("SA2",cLjCDDis+cLjLODis) Picture PesqPict("SF1","F1_LOJA") SIZE 08,8 OF oDlg PIXEL 
	
	@ 32,01 TO 56,130 LABEL STR0019 OF oDlg PIXEL   //"Nota - Serie "
	@ 40.5, 05 Say  STR0020  SIZE 30,8 OF oDlg PIXEL //"Nota"
	@ 40.5, 25 MSGET oDoc VAR cDoc Picture PesqPict("SF1","F1_DOC") Valid Lj470FrmtDoc(@cDoc,nTamDoc) SIZE 45,8 OF oDlg PIXEL
	@ 40.5, 80 Say  STR0021 SIZE 15,8 OF oDlg PIXEL  //"Serie"
	@ 40.5, 95 MSGET oSerie VAR cSerie Picture PesqPict("SF1","F1_SERIE") Valid Lj470VldDoc(cDoc,cSerie,cLjCDDis,cLjLODis) SIZE 08,8 OF oDlg PIXEL 
	
	DEFINE SBUTTON oOk   FROM 62,070 TYPE 1 ACTION (lRet:=.T., oDlg:End()) ENABLE OF oDlg
	DEFINE SBUTTON oCanc FROM 62,100 TYPE 2 ACTION (lRet:=.F., oDlg:End()) ENABLE OF oDlg
	
	ACTIVATE MSDIALOG oDlg CENTERED
	
	// Caso o usuario cancele a entrada da nota e seria a rotina e cancelada.
	If lRet
		
		aCab := {  	{"F1_FORNECE"   ,cLjCDDis									,NIL},;
					{"F1_LOJA"      ,cLjLODis									,NIL},;
					{"F1_SERIE"	 	,cSerie										,NIL},;
					{"F1_DOC"	 	,cDoc										,NIL},;			
					{"F1_TIPO"	 	,"N"  										,NIL},;
					{"F1_NATUREZ"   ,Space(TamSx3("F1_NATUREZ")[1])		   	,NIL},;
					{"F1_ESPECIE"   ,"RCN"+Space(TamSx3("F1_ESPECIE")[1] - 3)	,NIL},;
					{"F1_EMISSAO"	,NIL  										,NIL},;
					{"F1_DTDIGIT"	,dDataBase									,NIL},;
					{"F1_MOEDA"		,NIL  										,NIL},;
					{"F1_TXMOEDA"	,NIL  										,NIL},;
		  			{"F1_TIPODOC"	,"60"   									,NIL},;
					{"F1_FORMUL" 	,"N"										,NIL},;
					{"F1_COND"      ,NIL  										,NIL},;
					{"F1_EST"    	,Posicione("SA2",1,xFilial("SA2")+cLjCDDis+cLjLODis,"A2_EST"), NIL}}
		
		For nX := 1 To Len(aCab)
			nPos := aScan(aFieldsSF2,{|X| AllTrim(SubStr(X[1],3)) == Alltrim(SubStr(aCab[nX,1],3))})
			If nPos > 0 .AND. Empty(aCab[nX,2])
				aCab[nX,2] := aFieldsSF2[nPos,4]
			EndIf
		Next nX     
		
		// Itens do Remito...
		DbSelectArea("SF4")
		aAreaSF4 := GetArea()
		DbSetOrder(1)
		For nX := 1 To Len(aDadosSD2)
			aItens := {	{"D1_ITEM"   ,NIL ,NIL},;
						{"D1_COD"    ,NIL ,NIL},;
						{"D1_UM"     ,NIL ,NIL},;
						{"D1_QUANT"  ,NIL ,NIL},;
						{"D1_VUNIT"  ,NIL ,NIL},;
						{"D1_TOTAL"  ,NIL ,NIL},;
						{"D1_TES"    ,NIL ,NIL},;
						{"D1_CF"     ,NIL ,NIL},;
						{"D1_LOCAL"  ,NIL ,NIL}}
		
			For nY := 1 To Len(aItens)
				nPos := aScan(aFieldsSD2,{|X| Alltrim(SubStr(X[1],3)) == Alltrim(SubStr(aItens[nY,1],3))} )
				If nPos > 0
					aItens[nY,2] := aDadosSD2[nX,nPos]
				ElseIf AllTrim(aItens[nY,1]) == "D1_VUNIT"
					nPos := aScan(aFieldsSD2,{|X| Alltrim(X[1]) == "D2_PRCVEN"} )			
					aItens[nY,2] := aDadosSD2[nX,nPos]		
				EndIf
			Next nY
			
			nPos := aScan(aFieldsSD2,{|X| AllTrim(SubStr(X[1],3)) == '_TES'})
			If nPos > 0 
				// Sistema ira utilizar o TES de devolucao para entrada do item
				cTes := aDadosSD2[nX,nPos]
			    DbSeek(xFilial('SF4')+cTes)
			    If !Empty(SF4->F4_TESDV)
					cTes := SF4->F4_TESDV
		    	Else
					cTes := SuperGetMV("MV_TESENT")
		    	EndIf
		   	    DbSeek(xFilial('SF4')+cTes)
		
				nPos := aScan(aItens,{|X| AllTrim(X[1]) == "D1_TES"})
		     	aItens[nPos,2] := SF4->F4_CODIGO
		     	
				nPos := aScan(aItens,{|X| AllTrim(X[1]) == "D1_CF"})
			    aItens[nPos,2] := SF4->F4_CF
		
				AAdd(aTotItens,aItens)
			EndIf
		Next nX
		
		// Executa a rotina automatica para geracao do Remito de Entrada...            
		MSExecAuto({|x,y| Mata102N(x,y)},aCab,aTotItens)
		
		If lMsErroAuto
			DisarmTransaction()
			MostraErro()     
			lRet := .F.            
		Else             
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Ajuste no tamanho do arquivo a ser renomeado, pois antes o sistema considerava ³
			//³somente os 8 primeiros caracteres do arquivo                                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			FRename(cDirGrv+cFile,cDirGrv+SubStr(cFile,1,len(cfile)-4) +'.PRC')
		EndIf
		                     
		// Restaura as areas originais
		RestArea(aAreaSF4)
		RestArea(aAreaAtu)
	EndIf
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³Lj470FrmtDocºAutor  ³Vendas Clientes     º Data ³  04/06/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Descri‡…o ³ Valida o get do campo referente ao numero do documento de    º±± 
±±³          ³ entrada (remito) e o formata conforme o seu tamanho.         º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ºUso       ³ LOJA470()                                                    º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Lj470FrmtDoc(cDoc,nTamDoc)
Local lRet := .T.
Local nDoc := 0

lRet := NaoVazio(cDoc) 

If lRet       
	nDoc := Val(AllTrim(cDoc))
	cDoc := PadR( StrZero(nDoc,Len(cNota)) , nTamDoc )
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³Lj470VldDoc ºAutor  ³Vendas Clientes     º Data ³  04/06/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Descri‡…o ³ Verifica se nao existe na base de dados nenhum remito com    º±± 
±±³          ³ os dados informados.                                         º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ºUso       ³ LOJA470()                                                    º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Lj470VldDoc(cDoc,cSerie,cLjCDDis,cLjLODis)
Local aAreaAtu 	 := GetArea()
Local aAreaSF1 	 := {}
Local lRet     	 := .T.
Local nTamF1_DOC := TamSx3("F1_DOC")[1]		//Tamanho Nota Fiscal)

cDoc := PadR(cDoc,nTamF1_DOC)

DbSelectArea("SF1")                                                
aAreaSF1 := GetArea()
DbSetOrder(1)
If DbSeek(xFilial("SF1")+cDoc+cSerie+cLjCDDis+cLjLODis+"N")
	While !Eof() .AND. F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO == ;
	      xFilial("SF1")+cDoc+cSerie+cLjCDDis+cLjLODis+"N"
	      
		If AllTrim(F1_ESPECIE) == "RCN"
			Help(' ', 1, 'JAGRAVADO')
	      	lRet   := .F.
	      	Exit
		EndIf
		DbSkip()
	End
EndIf                

// Restaura as areas originais...
RestArea(aAreaSF1)
RestArea(aAreaAtu)

Return lRet
