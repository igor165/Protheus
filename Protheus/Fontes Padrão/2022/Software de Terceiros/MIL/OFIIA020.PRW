// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 05     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#include "PROTHEUS.CH"
#include "OFIIA020.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ OFIIA020 ³ Autor ³  Renata               ³ Data ³ 01/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cad. de pecas atraves do dados importados no arquivo VI3   |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Estoque                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIIA020(cPreMar,nOpcx)

Private aCampos       := {}
Private aCamposCamTec := {}
Private aRotina       := MenuDef()
Private cCadastro := STR0004   //"Cadastro de Peca (Arquivo Montadora)"
Private cCodMar
Private cIndex , cChave , cCond
Private lAuto := .f.

nOpcx := IIf( nOpcx # NIL, nOpcx, 3 )

If cPreMar # NIL
	lAuto := .t.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If lAuto
	
	Pergunte("OFIMAR",.f.)
	
	MV_PAR01 := cPreMar
	
Else
	
	if !Pergunte("OFIMAR",.t.)
		Return
	Endif
	
Endif

cCodMar := MV_PAR01

dbSelectArea("VI3")
cIndex  := CriaTrab(nil,.f.)
cChave  := IndexKey()
cCond   := 'VI3->VI3_CODMAR==cCodMar'
IndRegua("VI3",cIndex,cChave,,cCond,STR0005) //"Filtrando"

DbSelectArea("VI3")
nIndex := RetIndex("VI3")+1
#IFNDEF TOP
	dbSetIndex(cIndex+ordBagExt())
#ENDIF
dbSetOrder(nIndex)

If lAuto
	
	If nOpcx == 2
		IA020V(Alias(),VI3->(Recno()),nOpcx)
	ElseIf nOpcx == 3
		IA020A(Alias(),VI3->(Recno()),nOpcx)
	EndIf
	
Else
	
	mBrowse( 6, 1,22,75,"VI3")     //,,,,"VI3_CODMAR = cMarca")
	
EndIf

dbSelectArea("VI3")
RetIndex()
DbsetOrder(1)
#IFNDEF TOP
	If File(cIndex+OrdBagExt())
		fErase(cIndex+OrdBagExt())
	Endif
#ENDIF

return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³IA020A    ³ Autor ³Renata                 ³ Data ³ 01/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ chama a funcao fs_gravapec, feito dessa forma por causa do ³±±
±±³          ³ termometro                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function IA020A(cAlias,nReg,nOpc)
Private aRotina := {{  ,"", , 3},;
					{  ,"", , 3},;
					{  ,"", , 3}}
Private lMSHelpAuto := .t. , lMSErroAuto := .f. , lRet := .t.
Processa( {|| FS_GRAVAPEC() } )
If !lRet
	MostraErro()
EndIf
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_GRAVAPEC³ Autor ³Renata                ³ Data ³ 01/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao que monta o vetor do Item e chama o MATA010         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_GRAVAPEC()

Local lAcheiSB1 := .t., cCodFor := "", cLojFor := ""
Private nPrePLu := 0 , nVAlVda := 0
Private cCtaCtb , cCenCus , cAlmox , cTesEnt , cTesSai , cCodFab , cGruIte , cPecInt
Private aIncSB1:= {}

FG_SEEK("VE4","VI3->VI3_CODMAR",1,.F.)
cCtaCtb := VE4->VE4_CTACTB
cCenCus := VE4->VE4_CENCUS
cAlmox  := VE4->VE4_ALMPAD
cTesEnt := VE4->VE4_TESENT
cTesSai := VE4->VE4_TESSAI
cCodFab := VE4->VE4_CODFAB
cGruIte := VE4->VE4_GRUITE
cGruDeS := VE4->VE4_GRUDES
cFEstCo := IIf(VE4->VE4_FESTCO="0","N","S")

FG_SEEK("VE1","VI3->VI3_CODMAR",1,.F.)
cFabric := left(VE1->VE1_DESMAR,20)

DbSelectArea("VI3")
DbSeek(xFilial("VI3"))

If !Empty(FG_TRANSACTION("OFIIA020","VI3",,,.F.))
	DbGoTo(FG_TRANSACTION("OFIIA020","VI3",,,.F.))
EndIf

ProcRegua( VI3->(reccount()) )

do while !Eof() .And. VI3->VI3_FILIAL == xFilial("VI3")
	
	nTransaction:=0
	
	Begin Transaction
	
	do while FG_TRANSACTION("OFIIA020","VI3",++nTransaction,RecNo(),(Eof() .Or. VI3->VI3_FILIAL # xFilial("VI3")),"L") .And. !Eof() .And. VI3->VI3_FILIAL == xFilial("VI3")
		
		cCodFor := VE4->VE4_CODFOR
		cLojFor := VE4->VE4_LOJFOR
		If !Empty(VI3->VI3_CODFOR) .and. !Empty(VI3->VI3_LOJFOR)
			cCodFor := VI3->VI3_CODFOR
			cLojFor := VI3->VI3_LOJFOR
		EndIf
		
		lAcheiSB1 := FG_SEEK("SB1","cGruIte+VI3->VI3_CODITE",7,.F.)
		
		if lAcheiSB1
			do while !SB1->(eof()) .AND. SB1->B1_GRUPO+SB1->B1_CODITE == cGruIte+VI3->VI3_CODITE .and. SB1->B1_FILIAL == xFilial("SB1")
				FG_SEEK("SBM","SB1->B1_GRUPO",1,.F.)
				if SBM->BM_CODMAR == cCodMar
					lAcheiSB1 := .T.
					exit
				endif
				SB1->(DBSKIP())
				lAcheiSB1 := .F.
			enddo
		endif
		
		if !empty(VI3->VI3_GRUDST)                
			cGrudes := VI3->VI3_GRUDST
			if FG_SEEK("VE5","VI3->VI3_CODMAR+VI3->VI3_GRUDST",1,.F.)=.f.
				dbSelectArea("VE5")
				RecLock("VE5",.T.)
				VE5->VE5_FILIAL := xFilial("VI3")
				VE5->VE5_CODMAR := VI3->VI3_CODMAR
				VE5->VE5_GRUDST := VI3->VI3_GRUDST
				VE5->VE5_FORVDA := getmv("MV_FORPADV")
				MsUnlock()
			endif
		else
			dbselectarea("VE5")
			dbseek(xFilial("VE5")+VI3->VI3_CODMAR+cGrudes)
			DbSelectArea("VI3")
		endif
		
		FG_SEEK("VEG","VE5->VE5_FORVDA",1,.F.)
		nPrePlu := VI3->VI3_PREPLU
		nValVda := &(VEG->VEG_FORMUL)      //VEZES O INDICE DE CORRECAO, CASO HAJA
		If nValVda==nil
			MsgStop(STR0007+cGrudes,STR0008)
			nValVda := 0
			lRet := .f.
			Disarmtransaction()
			Break
		Endif
		
		if !lAcheiSB1
			
			If ExistBlock("EDISB1TE")
				cTesEnt := ExecBlock("EDISB1TE",.f.,.f.,{cTesEnt})
			Endif
			If ExistBlock("EDISB1TS")
				cTesSai := ExecBlock("EDISB1TS",.f.,.f.,{cTesSai})
			Endif
			
			cPecInt := GetSXENum("SB1","B1_COD")
			ConfirmSX8()
			
			aIncSB1:= {}
			aAdd(aIncSB1,{"B1_COD"     ,cPecInt               ,Nil}) // Codigo
			aAdd(aIncSB1,{"B1_CODITE"  ,VI3->VI3_CODITE		 ,Nil}) // Codigo
			aAdd(aIncSB1,{"B1_DESC"    ,VI3->VI3_DESCRI      ,Nil}) // Descricao
			aAdd(aIncSB1,{"B1_TIPO"    ,"ME"                  ,Nil}) // Tipo do Produto
			aAdd(aIncSB1,{"B1_UM"      ,"PC"                  ,Nil}) //
			aAdd(aIncSB1,{"B1_SEGUM"   ,"PC"                  ,Nil}) //
			aAdd(aIncSB1,{"B1_LOCPAD"  ,cAlmox                ,Nil}) //
			aAdd(aIncSB1,{"B1_PICM"    ,0                     ,Nil}) //
			aAdd(aIncSB1,{"B1_IPI"     ,VI3->VI3_ALQIPI       ,Nil}) //
			aAdd(aIncSB1,{"B1_TE"      ,cTesEnt                ,Nil}) //
			aAdd(aIncSB1,{"B1_TS"      ,cTesSai                ,Nil}) //
			if nValVda >= VE5->VE5_ALTVLR
				aAdd(aIncSB1,{"B1_PRV1" ,nValVda                ,Nil}) //
			endif
			aAdd(aIncSB1,{"B1_CONTA"   ,cCtaCtb                ,Nil}) //
			if !empty(cCenCus)
				aAdd(aIncSB1,{"B1_CC"   ,cCenCus                 ,Nil}) //
			endif
			aAdd(aIncSB1,{"B1_TIPOCQ"  ,"M"                     ,Nil}) //
			aAdd(aIncSB1,{"B1_FABRIC"  ,cFabric                 ,Nil}) //
			aAdd(aIncSB1,{"B1_CONTRAT" ,"N"                     ,Nil}) //
			aAdd(aIncSB1,{"B1_LOCALIZ" ,"N"                     ,Nil}) //
			aAdd(aIncSB1,{"B1_IRRF"    ,"N"                     ,Nil}) //
			aAdd(aIncSB1,{"B1_CONTSOC" ,"N"                     ,Nil}) //
			aAdd(aIncSB1,{"B1_GRUPO"   ,cGruIte                 ,Nil}) // Grupo
			aAdd(aIncSB1,{"B1_ENVOBR"  ,"0"                     ,Nil}) //
			aAdd(aIncSB1,{"B1_QE    "  ,VI3->VI3_QTMIN1         ,Nil}) //
			aAdd(aIncSB1,{"B1_PESO"    ,VI3->VI3_PESITE         ,Nil}) //
			aAdd(aIncSB1,{"B1_GRUDES"  ,VI3->VI3_GRUDST			  ,Nil}) //
			aAdd(aIncSB1,{"B1_SITPROD" ,"N"                      ,Nil}) //
			aAdd(aIncSB1,{"B1_SEGUN"   ,"PC"                     ,Nil}) //
			aAdd(aIncSB1,{"B1_MONO"    ,"S"                      ,Nil}) //
			aAdd(aIncSB1,{"B1_FLAGSUG" ,"1"                      ,Nil}) //
			aAdd(aIncSB1,{"B1_CLASSVE" ,"1"                      ,Nil}) //
			aAdd(aIncSB1,{"B1_APROPRI" ,"D"                      ,Nil}) //
			aAdd(aIncSB1,{"B1_FANTASM" ,"N"                      ,Nil}) //
			aAdd(aIncSB1,{"B1_TIPODEC" ,"N"                      ,Nil}) //
			aAdd(aIncSB1,{"B1_UREV   " ,DDATABASE                ,Nil}) //
			aAdd(aIncSB1,{"B1_PERINV"  ,180                    ,Nil}) //
			aAdd(aIncSB1,{"B1_GRADE"   ,"N"                      ,Nil}) //
			aAdd(aIncSB1,{"B1_PROC"    ,cCodFor                  ,Nil}) //
			aAdd(aIncSB1,{"B1_LOJPROC" ,cLojFor				         ,Nil}) //
			aAdd(aIncSB1,{"B1_FORAEST" ,cFestCo                  ,Nil}) //
			aAdd(aIncSB1,{"B1_ANUENTE" ,"2"                      ,Nil}) //
			aAdd(aIncSB1,{"B1_BALANCA" ,"0"                      ,Nil}) //
			aAdd(aIncSB1,{"B1_IMPZFRC" ,"N"                      ,Nil}) //
			aAdd(aIncSB1,{"B1_CONV"    ,1                        ,Nil}) //
			aAdd(aIncSB1,{"B1_ORIGEM"  ,"000"                    ,Nil}) //
			aAdd(aIncSB1,{"B1_DTREFP1" ,dDataBase                ,Nil}) //
			aAdd(aIncSB1,{"B1_POSIPI"  ,VI3->VI3_CLAFIS          ,Nil}) //
			aAdd(aIncSB1,{"B1_CLASSE"  ,VI3->VI3_CLASSE          ,Nil})
			
			&& Campos da GM
			If SB1->(FieldPos("B1_CATALO")) # 0
				aAdd(aIncSB1,{"B1_CATALO"  ,VI3->VI3_CATALO          ,Nil})
			EndIf
			If SB1->(FieldPos("B1_LOTED")) # 0
				aAdd(aIncSB1,{"B1_LOTED"  ,VI3->VI3_LOTED            ,Nil})
			EndIf
			If SB1->(FieldPos("B1_LOTEAT")) # 0
				aAdd(aIncSB1,{"B1_LOTEAT"  ,VI3->VI3_LOTEAT          ,Nil})
			EndIf
			If SB1->(FieldPos("B1_STATUS")) # 0
				aAdd(aIncSB1,{"B1_STATUS"  ,VI3->VI3_STATUS          ,Nil})
			EndIf
			If SB1->(FieldPos("B1_NCM")) # 0
				aAdd(aIncSB1,{"B1_NCM"     ,VI3->VI3_NCM             ,Nil})
			EndIf
			If SB1->(FieldPos("B1_FLAGMN")) # 0
				aAdd(aIncSB1,{"B1_FLAGMN"  ,VI3->VI3_FLAGMN          ,Nil})
			EndIf
			
			lMSHelpAuto := .t.
			lMSErroAuto := .f.
			
			MSExecAuto({|x| mata010(x)},aIncSB1)
			
			if !lMSErroAuto   //deu certo  , se retornar .t. deu erro
				
				lAcheiSB1 := .t.
				
			else
				
				lRet := .f.
				Disarmtransaction()
				Break
				
			endif
			
		Else
			
			cPecInt := SB1->B1_COD
			
			If nValVda >= VE5->VE5_ALTVLR   // QDO O CADASTRO NO SB1 JA EXISTE EU SO ATUALIZO O B1_PRV1
				
				dbselectarea("SB1")
				
				If !RECLOCK("SB1",.F.)
					Help("  ",1,"REGNLOCK")
					lRet := .f.
					DisarmTransaction()
					Break
				EndIf
				
				SB1->B1_DESC   := IIf( !Empty(VI3->VI3_DESCRI), VI3->VI3_DESCRI, SB1->B1_DESC   )
				SB1->B1_IPI    := IIf( !Empty(VI3->VI3_ALQIPI), VI3->VI3_ALQIPI, SB1->B1_IPI    )
				SB1->B1_POSIPI := IIf( !Empty(VI3->VI3_CLAFIS), VI3->VI3_CLAFIS, SB1->B1_POSIPI )
				SB1->B1_QE     := IIf( !Empty(VI3->VI3_QTMIN1), VI3->VI3_QTMIN1, SB1->B1_QE     )
				SB1->B1_PESO   := IIf( !Empty(VI3->VI3_PESITE), VI3->VI3_PESITE, SB1->B1_PESO   )
				SB1->B1_GRUDES := IIf( !Empty(VI3->VI3_GRUDST), VI3->VI3_GRUDST, SB1->B1_GRUDES )
				SB1->B1_PROC   := IIf( !Empty(cCodFor)        , cCodFor         , SB1->B1_PROC   )
				SB1->B1_LOJPROC:= IIf( !Empty(cLojFor)        , cLojFor         , SB1->B1_LOJPROC)
				SB1->B1_PRV1   := nValVda
				SB1->B1_CLASSE := VI3->VI3_CLASSE
				
				&& Campos da GM
				If SB1->(FieldPos("B1_CATALO")) # 0
					SB1->B1_CATALO := VI3->VI3_CATALO
				EndIf
				If SB1->(FieldPos("B1_LOTED")) # 0
					SB1->B1_LOTED := VI3->VI3_LOTED
				EndIf
				If SB1->(FieldPos("B1_LOTEAT")) # 0
					SB1->B1_LOTEAT := VI3->VI3_LOTEAT
				EndIf
				If SB1->(FieldPos("B1_STATUS")) # 0
					SB1->B1_STATUS := VI3->VI3_STATUS
				EndIf
				If SB1->(FieldPos("B1_NCM")) # 0
					SB1->B1_NCM := VI3->VI3_NCM
				EndIf
				If SB1->(FieldPos("B1_FLAGMN")) # 0
					SB1->B1_FLAGMN := VI3->VI3_FLAGMN
				EndIf
				
				MSUNLOCK()
				
			EndIf
			
			If lAcheiSB1
				
				dbselectarea("SB5")
				DbSetOrder(1)
				DbSeek( xFilial("SB5") + cPecInt )
				
				If !RecLock("SB5", !Found() )
					Help("  ",1,"REGNLOCK")
					lRet := .f.
					DisarmTransaction()
					Break
				EndIf
				
				SB5->B5_FILIAL := xFilial("SB5")
				SB5->B5_COD    := cPecInt
				SB5->B5_PRV2   := VI3->VI3_PREREP
				SB5->B5_PRV3   := VI3->VI3_PREGAR
				SB5->B5_CEME   := IIf( !Empty(VI3->VI3_DESCRI) , VI3->VI3_DESCRI, SB5->B5_CEME )
				SB5->B5_DTREFP2:= dDataBase
				SB5->B5_DTREFP3:= dDataBase
				
				If SB5->( FieldPos("B5_CODFAB") ) # 0
					SB5->B5_CODFAB := VI3->VI3_CODFAB
				EndIf
				
				&& Campos da GM
				SB5->B5_PRV4 := VI3->VI3_PREPL1
				SB5->B5_PRV5 := VI3->VI3_PREPL2
				
				MsUnLock()
				
			EndIf
			
		EndIf
		
		If ExistBlock("IA020DPG")
			ExecBlock("IA020DPG",.f.,.f.,{cPecInt})
		EndIf
		
		IncProc(STR0006)    //"Atualizando cadastro de Pecas!!"
		
		dbselectArea("VI3")
		
		If !RecLock("VI3",.F.,.T.)
			Help("  ",1,"REGNLOCK")
			lRet := .f.
			DisarmTransaction()
			Break
		EndIf
		
		dbdelete()
		MsUnlock()
		WriteSx2("VI3")
		
		dbskip()
		
	enddo
	
	End Transaction
	
	If !lRet
		Exit
	EndIf
	
enddo

If lRet
	
	DbSelectArea("VI3")
	DbCloseArea()
	If ChkFile("VI3",.T.)
		Pack
		DbCloseArea()
	EndIf
	ChkFile("VI3",.F.)
	
	dbSelectArea("VI3")
	cIndex  := CriaTrab(nil,.f.)
	cChave  := IndexKey()
	cCond   := 'VI3->VI3_CODMAR==cCodMar'
	IndRegua("VI3",cIndex,cChave,,cCond,STR0005) //"Filtrando"
	
	DbSelectArea("VI3")
	nIndex := RetIndex("VI3")+1
	#IFNDEF TOP
		dbSetIndex(cIndex+ordBagExt())
	#ENDIF
	dbSetOrder(nIndex)
	dbGoTop()
	
EndIf

return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³IA020V    ³ Autor ³Renata                 ³ Data ³ 25/11/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ visualiza os dados dos arquivos                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function IA020V(cAlias,nReg,nOpc)

CPOIA020()
AxVisual(cAlias,nReg,nOpc,aCampos)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³CPOIA020  ³ Autor ³Renata                 ³ Data ³ 01/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Pega os campos no SX3 para serem mostrados na visualizacao  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CPOIA020()
DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("VI3")
aCampos := {}
Do While !Eof() .And. x3_arquivo == "VI3"
	If X3USO(x3_usado) .And. cNivel>=x3_nivel
		aadd(aCampos,x3_campo)
	EndIf
	DbSkip()
Enddo
DbSelectArea("VI3")
Return

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MenuDef  ³ Autor ³Renata                 ³ Data ³ 01/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Monta aRotina ( MenuDef )                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()
Local aRotina := {	{ STR0001 ,"AxPesqui", 0 , 1},;  //"Pesquisar"
					{ STR0002 ,"IA020V", 0 , 2},;     //"Visualizar"
					{ STR0003 ,"IA020A", 0 , 3  }}    //"Atualizar"
Return aRotina