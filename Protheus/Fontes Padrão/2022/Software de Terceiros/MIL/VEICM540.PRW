// 浜様様様曜様様様様�
// � Versao � 0     �
// 藩様様様擁様様様様�

#INCLUDE "VEICM540.ch"
#Include "PROTHEUS.CH"
#DEFINE nMaxRight (oDlgChk:nClientWidth/2)
#DEFINE nMaxHeight (oDlgChk:nClientHeight/2)
/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Fun��o    � VEICM540 � Autor �  Ricardo Farinelli    � Data � 12/02/01 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descri��o � Manutencao do check-list de entrega do veiculo             咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Sintaxe   �                                                            咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Uso       � Gestao de Concessionarias                                  咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
FUNCTION VEICM540
Private aRotina := MenuDef()
Private cCadastro := OemtoAnsi(STR0007) //"Check-list de Entrega do Veiculo"
dbSelectArea("VAH")
dbSetOrder(1)        
mBrowse( 6, 1,22,75,"VAH")
Return
  
/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼浜様様様様用様様様様様僕様様様冤様様様様様様様様様曜様様様冤様様様様様様傘�
臼�Programa  �VEICM540I �Autor  �Ricardo Farinelli   � Data �  11/01/02   艮�
臼麺様様様様謡様様様様様瞥様様様詫様様様様様様様様様擁様様様詫様様様様様様恒�
臼�Desc.     �Trata a manutencao do check-list de entrega                 艮�
臼�          �                                                            艮�
臼麺様様様様謡様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様恒�
臼�Uso       � Gestao de Concessionarias                                  艮�
臼藩様様様様溶様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様識�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/

Function VEICM540I(cAlias,nReg,nOpc)
Local nOpcG
Local nOpcao := 0
Local cLinOk := "CM540LINOK()", cTudoOk := "CM540TUDOK()", cFieldOk := "CM540FILOK()"
Local nwnk   := 0
Private cNumTra := VAH->VAH_NUMTRA
Private nOpcX := nOpc
Private oGetDados
Private aHeader := {}, aCols := {}
Private oNumTra,oDescri
RegToMeMory("VAH",Inclui)
nOpcG := nOpcX
If Empty(cNumTra)
	Help(" ",1,"VCM540INC")
	Return .F.
Endif
CM540aHeader("VAH","aHeader","VAH_NUMTRA") // Monta aHeader/aCols para o VAH
CM540aCols("VAH",1,xFilial("VAH")+cNumTra,"aCols","VAH_FILIAL+VAH_NUMTRA") // Monta aCols para o VAH

// Carrega as descricoes da getdados de checklist
If !Inclui
	For nwnk := 1 To Len(aCols)
		// Carrega a Descricao do Grupo para o campo do aCols
		aCols[nwnk,FG_POSVAR("VAH_DESCRI")] := CM540Desc("VAF",aCols[nwnk,FG_POSVAR("VAH_CODIGO")],1,FG_POSVAR("VAH_DESCRI"),"VAF_DESCRI")
	Next	
Endif

CM540PESQ(cNumTra) // posiciona nos dados complementares do cabecalho

DEFINE MSDIALOG oDlgChk FROM 000,000 TO 337,600 TITLE OemToAnsi(cCadastro) OF oMainWnd PIXEL

@ 018,002 SAY OemtoAnsi(STR0008) 	SIZE 40,08 OF oDlgChk PIXEL COLOR CLR_BLUE //"Numero Documento"
@ 018,065 SAY OemToAnsi(STR0009) 				SIZE 40,08 OF oDlgChk PIXEL COLOR CLR_BLUE //"Chassi"
@ 018,150 SAY OemToAnsi(STR0010)				SIZE 40,08 OF oDlgChk PIXEL COLOR CLR_BLUE //"Cliente"

@ 018,030 SAY OemToAnsi(cNumTra) 				SIZE 40,08 OF oDlgChk PIXEL COLOR CLR_BLACK
@ 018,090 SAY OemToAnsi(VV1->VV1_CHASSI) 		SIZE 50,08 OF oDlgChk PIXEL COLOR CLR_BLACK
If Left(cNumtra,2)==STR0011 //"OS"
	@ 018,175 SAY OemToAnsi(VO1->VO1_PROVEI+"/"+VO1->VO1_LOJPRO+" "+SA1->A1_NOME) SIZE 150,08 OF oDlgChk PIXEL COLOR CLR_BLACK
Else
	@ 018,175 SAY OemToAnsi(VV0->VV0_CODCLI+"/"+VV0->VV0_LOJA+" "+SA1->A1_NOME) SIZE 150,08 OF oDlgChk PIXEL COLOR CLR_BLACK
Endif

@ 030,002 SAY OemToAnsi(STR0012) 					SIZE 40,08 OF oDlgChk PIXEL COLOR CLR_BLUE //"Tipo"
@ 030,030 SAY OemToAnsi(Iif(Left(cNumtra,2)==STR0011,STR0013,; //"OS"###"Check-List de entrega de veiculo de Ordem de Servico"
																	STR0014)) OF oDlgChk PIXEL COLOR CLR_BLACK //"Check-List de entrega de veiculo de Veiculo Vendido"

oGetDados  := MSGetDados():New(040,000,nMaxHeight,nMaxRight, nOpcX,cLinOk,cTudoOk,"",If(nOpcX > 2 .and. nOpcX < 4,.t.,.f.),,1,,,cFieldOk)

ACTIVATE MSDIALOG oDlgChk CENTER ON INIT Enchoicebar(oDlgChk,{||nOpcao := 1,If(!CM540TUDOK(),nOpcao:= 0,oDlgChk:End())},{||nOpcao := 2,oDlgChk:End()})

If nOpcao==1
	Fs_Grv540Cm(nOpc)
Endif	
Return

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼浜様様様様用様様様様様僕様様様冤様様様様様様様様様曜様様様冤様様様様様様傘�
臼�Programa  �CM540aHeader      �Ricardo Farinelli   � Data �  11/01/02   艮�
臼麺様様様様謡様様様様様瞥様様様詫様様様様様様様様様擁様様様詫様様様様様様恒�
臼�Desc.     �Monta o aHeader conforme o Alias informado                  艮�
臼�Parametros�cAlias     = alias do arquivo a ser montado                 艮�
臼�          �cAheader   = nome da variavel array a ser criado            艮�
臼�          �cNaoCpo    = campos para excluir da getdados                艮�
臼麺様様様様謡様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様恒�
臼�Uso       � Gestao de Concessionarias                                  艮�
臼藩様様様様溶様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様識�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/

Static Function CM540aHeader(cAlias,cheader,cNaoCpo)
	Local aAlias := sGetaRea()
	sGetArea(aAlias,Alias())
 	
	dbSelectArea("SX3")
	dbSetOrder(1)
	Dbseek(cAlias)
	While !Eof() .And. (SX3->X3_ARQUIVO == cAlias)
		IF X3USO(SX3->X3_USADO) .AND. cNivel >= SX3->X3_NIVEL .and. Iif(cNaoCpo<>Nil,!SX3->X3_CAMPO$cNaoCpo,.T.)
			AADD(&(cHeader),{ TRIM(x3titulo()),;
				SX3->X3_CAMPO,;
				SX3->X3_PICTURE,;
				SX3->X3_TAMANHO,;
				SX3->X3_DECIMAL,;
				SX3->X3_VALID,;
				SX3->X3_USADO,;
				SX3->X3_TIPO,;
				SX3->X3_ARQUIVO,;
				SX3->X3_CONTEXT,;
				SX3->X3_RELACAO,;
				SX3->X3_RESERV })
		EndIf
		dbSelectArea("SX3")		
		dbSkip()
	EndDo
   sRestArea(aAlias)
Return

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼浜様様様様用様様様様様僕様様様冤様様様様様様様様様曜様様様冤様様様様様様傘�
臼�Programa  �CM540aCols        �Ricardo Farinelli   � Data �  11/01/02   艮�
臼麺様様様様謡様様様様様瞥様様様詫様様様様様様様様様擁様様様詫様様様様様様恒�
臼�Desc.     �Monta o aHeader conforme o Alias informado                  艮�
臼�Parametros�cAlias     = alias do arquivo a ser montado                 艮�
臼�          �nOrdem     = Ordem do arquivo em caso de alteracao/exc/vis. 艮�
臼�          �cChave     = Chave de pesquisa em caso de alt/exc/vis.      艮�
臼�          �cAcols     = variavel que ira receber o conteudo            艮�
臼�          �cCond      = variavel de escopo da tabela para alt/exc/vis. 艮�
臼麺様様様様謡様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様恒�
臼�Uso       � Gestao de Concessionarias                                  艮�
臼藩様様様様溶様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様識�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/

Static Function CM540aCols(cAlias,nOrdem,cChave,caCols,cCond)
	Local nY
	Local aAlias := sGetArea()
	sGetArea(aAlias,Alias())
	sGetArea(aAlias,cAlias)
	
	&(cAlias)->(DbsetOrder(nOrdem))
	If &(cAlias)->(Dbseek(cChave))
		DbselectArea(cAlias)
		Do While &(cAlias)->(&cCond) == cChave .and. !(&(cAlias)->(Eof()))
			aadd(&(cACols),Array(Len(&("aHeader"))+1))
	      For ny:=1 to Len(&("aHeader"))
	          &(cACols)[Len(&(cACols)),ny]:=If(&("aHeader")[ny,10] # "V",FieldGet(FieldPos(&("aHeader")[ny,2])),CriaVar(&("aHeader")[ny,2],Inclui))
	      Next
         &(cACols)[Len(&(cACols)),Len(&(cACols)[Len(&(cACols))])] := .f.
			&(cAlias)->(Dbskip())
		Enddo			
	Else
		aadd(&(cACols),Array(Len(&("aHeader"))+1))
		For nY := 1 To Len(&("aHeader"))
			&(cACols)[1][nY] := CriaVar(&("aHeader")[nY][2])
		Next nY
		&(cACols)[1][Len(&(cACols)[1])] := .F.
	Endif
	sRestArea(aAlias)
Return

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼浜様様様様用様様様様様僕様様様冤様様様様様様様様様曜様様様冤様様様様様様傘�
臼�Programa  �CM540LINOK�Autor  �Ricardo Farinelli   � Data �  11/01/02   艮�
臼麺様様様様謡様様様様様瞥様様様詫様様様様様様様様様擁様様様詫様様様様様様恒�
臼�Desc.     �Valida a Linha Digitada nas GetDados                        艮�
臼�Parametros�nx - opcional, numero da linha a validar                    艮�
臼�          �lTudook - opcional, ind.a chamada da rotina pela tudook     艮�
臼麺様様様様謡様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様恒�
臼�Uso       � Gestao de Concessionarias                                  艮�
臼藩様様様様溶様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様識�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/

Function CM540LINOK(nX,lTudook)
Local nwnk := 0,nwnk2 := 0,cChave
Local nPos := 0
Default lTudook := .F.

cChave := 	"VAH_CODIGO"

If nX<>Nil
	n := nX
Endif	

nPos := Iif(nPos<>0,nPos,FG_POSVAR(cChave))

// Testa para saber se existem itens validos na linha do acols
lValid := .F.
For nwnk2 := 1 To Len(aCols)
	If !aCols[nwnk2,Len(aCols[nwnk2])] 
		For nwnk := 1 To Len(aCols[nwnk2])-1
			If !Empty(aCols[nwnk2,nwnk])
				lValid := .T.
				Exit
			Endif
		Next
	Endif
Next
If !lValid .and. !lTudook
	lValid := .T.
Endif	
If Len(aCols) > 1
	lValid := .T.
Endif	
	
If lValid
	For nwnk := 1 to Len(aCols)
		If !aCols[nwnk,Len(aCols[nwnk])] .and. nwnk <> n .and.;
			aCols[nwnk,nPos] == aCols[n,nPos] .and. !aCols[n,Len(aCols[n])]
  			Help(" ",1,"EXISTCHAV")
  			Return (.F.)
		Endif
		If !aCols[nwnk,Len(aCols[nwnk])] .and. Empty(aCols[nwnk,nPos])
			Help(" ",1,"OBRIGAT")
			Return (.F.)					
		Endif
	Next
	If !FG_OBRIGAT()
		Return .F.
	Endif
Endif	
Return (.T.)

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼浜様様様様用様様様様様僕様様様冤様様様様様様様様様曜様様様冤様様様様様様傘�
臼�Programa  �CM540TUDOK�Autor  �Ricardo Farinelli   � Data �  11/01/02   艮�
臼麺様様様様謡様様様様様瞥様様様詫様様様様様様様様様擁様様様詫様様様様様様恒�
臼�Desc.     �Valida a Tela Toda digitada                                 艮�
臼�          �                                                            艮�
臼麺様様様様謡様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様恒�
臼�Uso       � Gestao de Concessionarias                                  艮�
臼藩様様様様溶様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様識�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/

Function CM540TUDOK()
Local nwnk := 0

If !Inclui .and. !Altera
	Return .T.
Endif

For nwnk := 1 To Len(aCols)
	If !CM540LINOK(nwnk,.T.)
		Return (.F.)
	Endif
Next	

Return (.T.)


/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼浜様様様様用様様様様様僕様様様冤様様様様様様様様様曜様様様冤様様様様様様傘�
臼�Programa  �CM540FILOK�Autor  �Ricardo Farinelli   � Data �  11/01/02   艮�
臼麺様様様様謡様様様様様瞥様様様詫様様様様様様様様様擁様様様詫様様様様様様恒�
臼�Desc.     �Efetua a validacao de campos                                艮�
臼�          �                                                            艮�
臼麺様様様様謡様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様恒�
臼�Uso       � Gestao de Concessionarias                                  艮�
臼藩様様様様溶様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様識�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/

Function CM540FILOK()

If ReadVar()=="M->VAH_CODIGO"
	// Carrega a Descricao do Grupo para o campo do aCols
	aCols[n,FG_POSVAR("VAH_DESCRI")] := CM540Desc("VAF",M->VAH_CODIGO,1,FG_POSVAR("VAH_DESCRI"),"VAF_DESCRI")
Endif

Return (.T.)

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼浜様様様様用様様様様様僕様様様冤様様様様様様様様様曜様様様冤様様様様様様傘�
臼�Programa  �CM540Desc �Autor  �Ricardo Farinelli   � Data �  11/01/02   艮�
臼麺様様様様謡様様様様様瞥様様様詫様様様様様様様様様擁様様様詫様様様様様様恒�
臼�Desc.     �Atualiza a descricao do grupo generico                      艮�
臼�Parametros�cAlias    = alias do arquivo a atualizar                    艮�
臼�          �cCodigo   = Codigo a ser pesquisado na tabela informada     艮�
臼�          �nOrdem    = ordem do arquivo para a pesquisa (opcional)     艮�
臼�          �nPosCpo   = posicao do campo a ser atualizado no acols      艮�
臼�          �nCpoTab   = Nome do Campo que contem a descricao            艮�
臼麺様様様様謡様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様恒�
臼�Uso       � Gestao de Concessionarias                                  艮�
臼藩様様様様溶様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様識�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/

Function CM540Desc(cAlias,cCodigo,nOrdem,nPosCpo,cCpoTab)
Local cDescr := "",nTamCpo := aHeader[nPosCpo,4],aAlias := SGetArea()
Default nOrdem := 1
sGetArea(aAlias,Alias())
sGetArea(aAlias,cAlias)
DbselectArea(cAlias)
DbSetOrder(nOrdem)
cDescr := Space(nTamCpo)
If Dbseek(xFilial(cAlias)+cCodigo)
	cDescr := &(cCpoTab)
Endif
sRestArea(aAlias)
Return cDescr

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼浜様様様様用様様様様様僕様様様冤様様様様様様様様様曜様様様冤様様様様様様傘�
臼�Programa  �FS_GRV540CM       �Ricardo Farinelli   � Data �  11/01/02   艮�
臼麺様様様様謡様様様様様瞥様様様詫様様様様様様様様様擁様様様詫様様様様様様恒�
臼�Desc.     �Efetua a gravacao dos dados nos respectivos arquivos        艮�
臼�          �                                                            艮�
臼麺様様様様謡様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様恒�
臼�Uso       � Gestao de Concessionarias                                  艮�
臼藩様様様様溶様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様識�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/

Static Function FS_GRV540CM(nOpc)
Local lTrans := .F., lFound := .t.,nwnk
Local aTamCod := TamSX3("VAH_CODIGO")
Local nTamCod := aTamCod[1]

If nOpc <> 4
	Begin Transaction
		DbselectArea("VAH") // Estado Geral do Veiculo
		DbsetOrder(1)
		// Coloca os deletados primeiro
		Asort(aCols,,,{|x,y| x[len(x)] > y[Len(y)] })
		For nwnk := 1 To Len(aCols)
			If Empty(VAH->VAH_CODIGO) .and. DbSeek(xFilial("VAH")+cNumTra+Space(nTamCod))			
				lFound := .f.
			ElseIf Dbseek(xFilial("VAH")+cNumTra+aCols[nwnk,FG_POSVAR("VAH_CODIGO")])
			    lFound := .f.
			Else
				lFound := .t.
			EndIf
			RecLock("VAH",lFound)
			If aCols[nwnk,Len(aCols[nwnk])] .and. !lFound
				Dbdelete()
			Else
				FG_GRAVAR("VAH",aCols,aHeader,nwnk)
				VAH_NUMTRA := cNumTra
			Endif	
			MsUnlock()
		Next
	End Transaction
Elseif nOpc == 4
	Begin Transaction
		DbselectArea("VAH") // Estado Geral do Veiculo
		DbsetOrder(1)
		VAH->(Dbseek(xFilial("VAH")+cNumTra))
		Do While VAH->(VAH_FILIAL+VAH_NUMTRA) == xFilial("VAH")+cNumTra .and. !VAH->(Eof())
			RecLock("VAH",.F.)
			Dbdelete()
			MsUnLock()
			Dbskip()
		Enddo
   End Transaction
Endif
Return

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼浜様様様様用様様様様様僕様様様冤様様様様様様様様様曜様様様冤様様様様様様傘�
臼�Programa  �CM540PESQ �Autor  �Ricardo Farinelli   � Data �  01/11/02   艮�
臼麺様様様様謡様様様様様瞥様様様詫様様様様様様様様様擁様様様詫様様様様様様恒�
臼�Desc.     �Posiciona nas tabelas para compor o cabecalho da tela       艮�
臼�Parametros�cNumtra = que pode ser a OS ou a transacao de venda         艮�
臼麺様様様様謡様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様恒�
臼�Uso       � Gestao de Concessionarias                                  艮�
臼藩様様様様溶様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様識�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/

Static Function CM540PESQ(cNumTra)
Local aArqs := SGetArea()
sGetArea(aArqs,"VV1")
sGetArea(aArqs,"VV0")
sGetArea(aArqs,"VVA")
sGetArea(aArqs,"SA1")
sGetArea(aArqs,"VO1")
VV0->(DbsetOrder(1))
VVA->(DbSetOrder(1))
VV1->(DbSetOrder(1))
SA1->(DbSetOrder(1))
VO1->(DbSetOrder(1))

If Left(cNumTra,2)=="OS"
	VO1->(Dbseek(xFilial("VO1")+cNumTra))
	SA1->(Dbseek(xFilial("SA1")+VO1->(VO1_PROVEI+VO1_LOJPRO)))
	VV1->(Dbseek(xFilial("VV1")+VO1->VO1_CHAINT))
Else
	VV0->(Dbseek(xFilial("VV0")+cNumTra))
	VVA->(Dbseek(xFilial("VVA")+cNumTra))
	VV1->(Dbseek(xFilial("VV1")+VVA->VVA_CHAINT))
	SA1->(Dbseek(xFilial("SA1")+VV0->(VV0_CODCLI+VV0_LOJA)))
Endif	

Return

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼浜様様様様用様様様様様僕様様様冤様様様様様様様様様曜様様様冤様様様様様様傘�
臼�Programa  �VEICM540P �Autor  �Ricardo Farinelli   � Data �  11/01/02   艮�
臼麺様様様様謡様様様様様瞥様様様詫様様様様様様様様様擁様様様詫様様様様様様恒�
臼�Desc.     �Trata a impressao final do relatorio de check-list de entre-艮�
臼�          �ga do veiculo                                               艮�
臼麺様様様様謡様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様恒�
臼�Uso       � Gestao de Concessionarias                                  艮�
臼藩様様様様溶様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様識�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/

Function VEICM540P(cAlias,nReg,nOpc)
Local lProc := .T.
Private cNumTra := VAH->VAH_NUMTRA

If Empty(cNumTra)
	Help(" ",1,"VCM540INC")
	Return .F.
Endif

VAH->(Dbseek(xFilial("VAH")+cNumTra))
Do While VAH->(VAH_FILIAL+VAH_NUMTRA) == xFilial("VAH")+cNumTra .and. !VAH->(Eof())
	VAF->(Dbseek(xFilial("VAF")+VAH->VAH_CODIGO))
	If VAF->VAF_LIBENT=="0" .and. VAH->VAH_LIBST=="0"
		Help(" ",1,"CM540NLIB")
		lProc := .F.
		Exit
	Endif	
	Dbskip()
Enddo

If lProc
	// Chama a impressao da ficha
	VEIVR100(cNumTra,lProc)
Endif

Return

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼浜様様様様用様様様様様僕様様様冤様様様様様様様様様曜様様様冤様様様様様様傘�
臼�Programa  �CM540INC  �Autor  �Ricardo Farinelli   � Data �  01/11/02   艮�
臼麺様様様様謡様様様様様瞥様様様詫様様様様様様様様様擁様様様詫様様様様様様恒�
臼�Desc.     �Gera novo Registro na fila de check-list de entrega         艮�
臼�Parametros�cNumtra = que pode ser a OS ou a transacao de venda         艮�
臼�          �cTipo   = O - Os ou V - veiculo                             艮�
臼麺様様様様謡様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様恒�
臼�Uso       � Gestao de Concessionarias                                  艮�
臼藩様様様様溶様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様識�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/

Function CM540INC(cNumTra,cTipo)
Local lSeek := .F.
DbSelectArea("VAH")

If cTipo=="O"
	If VAH->(Dbseek(xFilial("VAH")+"OS"+cNumTra))
		lSeek := .T.
	Endif
Elseif cTipo == "V"
	If VAH->(Dbseek(xFilial("VAH")+cNumTra))
		lSeek := .T.
	Endif
	If !VVA->(Dbseek(xFilial("VVA")+cNumTra))
		Help(" ",1,"VEICHKEGR")
		Return
	Endif	
Endif

If !lSeek
	If cTipo=="O"
		If VAG->(Dbseek(xFilial("VAG")+VV1->(VV1_CODMAR+VV1_MODVEI+VV1_SEGMOD)))
			Do While VAG->(VAG_FILIAL+VAG_CODMAR+VAG_MODVEI+VAG_SEGMOD) == ;
						xFilial("VAG")+VV1->(VV1_CODMAR+VV1_MODVEI+VV1_SEGMOD) .and. !VAG->(Eof())
				Reclock("VAH",.T.)
				VAH->VAH_FILIAL := xFilial("VAH")
				VAH->VAH_NUMTRA := "OS"+cNumTra
				VAH->VAH_CODIGO := VAG->VAG_CODIGO
				VAH->VAH_LIBST  := "0"
				MsUnlock()	
				VAG->(Dbskip())
			Enddo
		Endif
	Elseif cTipo=="V"
		VVA->(DbsetOrder(1))                                
		VV1->(DbSetOrder(1))
		If VVA->(Dbseek(xFilial("VVA")+cNumTra)) .and. VV1->(DbSeek(xFilial("VV1")+VVA->VVA_CHAINT))
			If VAG->(Dbseek(xFilial("VAG")+VV1->(VV1_CODMAR+VV1_MODVEI+VV1_SEGMOD)))
				Do While VAG->(VAG_FILIAL+VAG_CODMAR+VAG_MODVEI+VAG_SEGMOD) == ;
							xFilial("VAG")+VV1->(VV1_CODMAR+VV1_MODVEI+VV1_SEGMOD) .and. !VAG->(Eof())
					Reclock("VAH",.T.)
					VAH->VAH_FILIAL := xFilial("VAH")
					VAH->VAH_NUMTRA := cNumTra
					VAH->VAH_CODIGO := VAG->VAG_CODIGO
					VAH->VAH_LIBST  := "0"
					MsUnlock()	
					VAG->(Dbskip())
				Enddo
			Endif
		Endif
	Endif
Endif

VEIVR100(cNumTra)

Return .T.

Static Function MenuDef()
/*
Local aRotina := { {OemtoAnsi(STR0001)	,"AxPesqui"	, 0 , 1},;  //Pequisar
                    {OemtoAnsi(STR0002) ,"VEICM540I", 0 , 2},;  //Visualizar
                    {OemtoAnsi(STR0003)	,"VEICM540I", 0 , 3},;	//Incluir
                    {OemtoAnsi(STR0004)	,"VEICM540I", 0 , 4},;	//Alterar
                    {OemtoAnsi(STR0005)	,"VEICM540I", 0 , 5},;	//Excluir
                    {OemtoAnsi(STR0006)	,"VEICM540P", 0 , 5}}  	//Impressao Final
*/
                    
Local aRotina := { {OemtoAnsi(STR0001)	,"AxPesqui"	, 0 , 1},;  //Pequisar
                    {OemtoAnsi(STR0002) ,"VEICM540I", 0 , 2},;  //Visualizar
                    {OemtoAnsi(STR0004)	,"VEICM540I", 0 , 4},;	//Alterar
                    {OemtoAnsi(STR0005)	,"VEICM540I", 0 , 5},;	//Excluir
                    {OemtoAnsi(STR0006)	,"VEICM540P", 0 , 5}}  	//Impressao Final                    
Return aRotina
