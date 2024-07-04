#INCLUDE "protheus.ch"
#INCLUDE "VEIVM140.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VEIVM140  ³ Autor ³ Manoel Filho         ³ Data ³ 17/11/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Disponibiliza Veiculo em Transito no ESTOQUE               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function VEIVM140()

Private cCondAd 	:= "Empty(VZK->VZK_DATSAI) .and. VZK->VZK_FILIAL==xFilial('VZK')" // Registros a disponibilizar
Private cCondDp 	:= "!Empty(VZK->VZK_DATSAI) .and. VZK->VZK_FILIAL==xFilial('VZK')" // Registros disponibilizados

Private cCadastro  	:= STR0001	//Disponibiliza Veiculo em Transito
Private aRotina    	:= MenuDef()
Private cMarca		:= ""
Private cGruVei    := GetMv("MV_GRUVEI")+space(4-len(GetMv("MV_GRUVEI")))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definição das colunas a serem mostradas no browser.       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCamList := {{'VZK_OK',  ,"",OemToAnsi("")},;
			{'VZK_CHASSI',"",OemToAnsi(STR0002)},;	//Chassi
			{'VZK_NUMNFI',"",OemToAnsi(STR0003)},;	///Nro. Nota
			{'VZK_SERNFI',"",OemToAnsi(STR0004)},;	//Serie
			{'VZK_CODFOR',"",OemToAnsi(STR0005)},;	//Fornecedor
			{'VZK_LOJA'  ,"",OemToAnsi(STR0006)},;	//Loja
			{'VZK_DATENT',"",OemToAnsi(STR0007)},;	//Data Entrada
			{'VZK_DATSAI',"",OemToAnsi(STR0008)}}	//Data Saida

cMarca     	:= GetMark()
lInvert	:= .F.			
DbSelectArea("VZK")
MarkBrow("VZK","VZK_OK",,aCamList,lInvert,cMarca,"VM140MBox(1)",,,,"VM140MBox(2)")
DbSelectArea("VZK")
DbSetOrder(1)

Return()

Function VM140MBox(nOpc)

If nOpc == 1 // Marcar todos
	dbSelectArea("VZK")
	dbGoTop()
	While !EOF()
		RecLock("VZK",.F.)
			VZK->VZK_OK := Iif(VZK->VZK_OK==cMarca,"",cMarca)
		MsUnLock()
		dbSkip()
	End
	dbGoTop()
Elseif nOpc == 2  // Marcar somente o registro posicionado
	RecLock("VZK",.F.)
		VZK->VZK_OK := Iif(VZK->VZK_OK==cMarca,"",cMarca)
	MsUnLock()
Endif

Return


Function VM140D()

Local lAchou := .F.

DbSelectArea("VZK")
DbGoTop()
While !Eof()	
	If VZK->VZK_OK <> cMarca
		dbSkip()
		Loop
	ElseIf VZK->VZK_OK == cMarca .and. Empty(VZK->VZK_DATSAI)
		lAchou := .T.
		Exit
	EndIf
	dbSkip()
	Loop
EndDo

If lAchou	
	If MsgYesNo(STR0009,cCadastro)//Confirma a disponibilizacao do(s) veiculo(s) para o Estoque?
		DbSelectArea("VZK")
		DbGoTop()
		While !Eof()
			If VZK->VZK_OK <> cMarca .or. !Empty(VZK->VZK_DATSAI)
				dbSkip()
				Loop
			Else	
				RecLock("VZK",.F.)
				VZK->VZK_DATSAI := dDataBase
				MsUnLock()
				DbSelectArea("VV1")
				DbSetOrder(2)
				If DbSeek(xFilial("VV1")+VZK->VZK_CHASSI,.T.)
					RecLock("VV1",.F.)
					VV1->VV1_SITVEI := "0"
					MsUnlock()
					DbSelectArea("SB1")
					DbSetOrder(7)
					If DbSeek(xFilial("SB1")+cGruVei+VV1->VV1_CHAINT)
						DbSelectArea("SB5")
						DbSetOrder(1)
						If DbSeek(xFilial("SB5")+SB1->B1_COD)
							if VV1->(FieldPos("B5_LOCALIZ")) <> 0
								RecLock("SB5",.F.)
								SB5->B5_LOCALIZ := "E"
								MsUnlock()
							Endif
					    Endif
					EndIf				
			    Endif
				DbSelectArea("VZK")
				dbSkip()
			EndIf
		EndDo
	EndIf
Else
	MsgAlert(STR0010,STR0011)//Confirma a disponibilizacao do(s) veiculo(s) para o Estoque? # Atencao
EndIf

Return

Static Function MenuDef()

Local aRotina := {{ STR0012 ,"axPesqui"				, 0 , 1},; 	//Pesquisar
              		{STR0013 ,"VM140D"  			, 0 , 2},;	//Disponibilizar
              		{STR0014 ,"VM140F(1)"  	, 0 , 3},;	//A Disponibilizar
              		{STR0015 ,"VM140F(2)"  	, 0 , 4},;	//Disponibilizados
              		{STR0016 ,"MsFilter('')"  		, 0 , 5},;	//Limpa Filtro
              		{STR0017 ,"BuildExpr('VZK')"	, 0 , 6}}	//Filtro
              		
Return aRotina                        

Function VM140F(nTipo)
Local cContarAd := "SELECT COUNT(*) FROM "+RetSqlName("VZK")+" WHERE VZK_DATSAI = ' ' AND VZK_FILIAL = '"+xFilial('VZK')+"' "	
Local cContarDp := "SELECT COUNT(*) FROM "+RetSqlName("VZK")+" WHERE VZK_DATSAI <> ' ' AND VZK_FILIAL = '" +xFilial('VZK')+"' "
      
If nTipo == 1 
	If FM_SQL(cContarAd) > 0
		MsFilter(cCondAd)
	Else
		MsgInfo(STR0018,STR0011) //Nao ha registros a disponibilizar!, Atencao! 
	EndIf		
ElseIf FM_SQL(cContarDp) > 0
	MsFilter(cCondDp)
Else
	MsgInfo(STR0019,STR0011) //Nao ha registros disponibilizados!, Atencao!
EndIf

Return