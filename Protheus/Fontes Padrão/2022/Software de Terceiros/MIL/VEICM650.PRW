// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 07     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#Include "PROTHEUS.CH"
#Include "VEICM650.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VEICM650 ³ Autor ³ Andre Luis Almeida         ³ Data ³ 23/08/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ CEV - Registro de Abordagem por Lote                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEICM650()
Local lCEVOUT   := ( VAI->(FieldPos("VAI_CEVOUT")) > 0 ) // Visualiza Agendas de Outros Usuarios do CEV? (1=Sim/0=Nao)
Local aObjects  := {} , aInfo := {}, aPos := {}
Local aSizeHalf := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local lTik      := .f.
Private oNo     := LoadBitmap( GetResources() , "LBNO" )	// Nao Selecionado
Private oTik    := LoadBitmap( GetResources() , "LBTIK" )	// Selecionado
Private aParCEV := {ctod(""),dDataBase,space(TamSx3("VC1_TIPAGE")[1]),space(TamSx3("VC1_CODVEN")[1]),space(TamSx3("VC1_CODCLI")[1]),space(TamSx3("VC1_LOJA")[1])}     
// 1 - Data Inicial
// 2 - Data Final 
// 3 - Tipo de Agenda
// 4 - Vendedor
// 5 - Cliente
// 6 - Loja
Private aVetCEV := {}
Private aBotCEV := {{"FILTRO" ,{|| IIf( FS_PARAM() , ( lTik := .f. , FS_FILTRA(.t.) ) , .t. ) },STR0008} } // Filtro

aInfo := { aSizeHalf[ 1 ], aSizeHalf[ 2 ],aSizeHalf[ 3 ] ,aSizeHalf[ 4 ], 3, 3 } // Tamanho total da tela
aAdd( aObjects, { 0 ,   0 , .T. , .T. } ) // ListBox TOTAL

aPos := MsObjSize( aInfo, aObjects )
//
VAI->(DbSetOrder(4))
VAI->(DbSeek( xFilial("VAI") + __CUSERID ))
If lCEVOUT .and. VAI->VAI_CEVOUT == "0" // Visualiza Agendas de Outros Usuarios do CEV? (1=Sim/0=Nao)
	aParCEV[4] := VAI->VAI_CODVEN
EndIf
//
FS_FILTRA(.f.) // Filtra - Levanta Agendas

DEFINE MSDIALOG oRegCEVLot FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] TITLE STR0001 OF oMainWnd PIXEL // CEV - Registro de Abordagem por Lote

@ aPos[1,1],aPos[1,2] LISTBOX oLbCEV FIELDS HEADER "",STR0002,STR0003,STR0004,STR0005,STR0006,STR0007 COLSIZES 10,18,28,45,90,50,80 ;
			SIZE aPos[1,4]-2,aPos[1,3]-aPos[1,1]+3 OF oRegCEVLot PIXEL ON DBLCLICK IIf(aVetCEV[oLbCEV:nAt,8]>0,(aVetCEV[oLbCEV:nAt,1]:=!aVetCEV[oLbCEV:nAt,1]),.t.)
oLbCEV:SetArray(aVetCEV)
oLbCEV:bLine := { || {	IIf(aVetCEV[oLbCEV:nAt,01],oTik,oNo),;
						aVetCEV[oLbCEV:nAt,02],;
						aVetCEV[oLbCEV:nAt,03],;
						aVetCEV[oLbCEV:nAt,04],;
						aVetCEV[oLbCEV:nAt,05],;
						aVetCEV[oLbCEV:nAt,06],;
						aVetCEV[oLbCEV:nAt,07] }}
oLbCEV:bHeaderClick := {|oObj,nCol| IIf( nCol==1 , ( lTik := !lTik , FS_TIK(lTik) ) , .t. ) , }

ACTIVATE MSDIALOG oRegCEVLot ON INIT EnchoiceBar(oRegCEVLot,{ || IIf(FS_REGISTRA(),FS_FILTRA(.t.),.t.) }, { || oRegCEVLot:End() },,aBotCEV)

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_PARAM ³ Autor ³ Andre Luis Almeida         ³ Data ³ 23/08/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Parametros para o Filtro do Levantamento das Agendas            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_PARAM()
Local lCEVOUT   := ( VAI->(FieldPos("VAI_CEVOUT")) > 0 ) // Visualiza Agendas de Outros Usuarios do CEV? (1=Sim/0=Nao)
Local aParamBox := {}
Local aRet      := {}
Local lRet      := .f.
//
VAI->(DbSetOrder(4))
VAI->(DbSeek( xFilial("VAI") + __CUSERID ))
If lCEVOUT .and. VAI->VAI_CEVOUT == "0" // Visualiza Agendas de Outros Usuarios do CEV? (1=Sim/0=Nao)
	aParCEV[4] := VAI->VAI_CODVEN
EndIf
//
AADD(aParamBox,{1,STR0009,aParCEV[1],"@D","","","",50,.f.}) // Data Inicial
AADD(aParamBox,{1,STR0010,aParCEV[2],"@D",'MV_PAR02>=MV_PAR01',"","",50,.f.}) // Data Final
AADD(aParamBox,{1,STR0011,aParCEV[3],"@!",'Empty(MV_PAR03) .or. FG_Seek("VC5","MV_PAR03",1)',"VC5","",25,.f.}) // Tipo de Agenda
AADD(aParamBox,{1,STR0004,aParCEV[4],"@!",'Empty(MV_PAR04) .or. FG_Seek("SA3","MV_PAR04",1)',"SA3",IIf(lCEVOUT.and.VAI->VAI_CEVOUT=="0",".F.",""),40,.f.}) // Vendedor
AADD(aParamBox,{1,STR0005,aParCEV[5],"@!",'Empty(MV_PAR05) .or. FG_Seek("SA1","MV_PAR05",1)',"SA1","",40,.f.}) // Cliente
AADD(aParamBox,{1,STR0012,aParCEV[6],"@!",'Empty(MV_PAR06) .or. FG_Seek("SA1","MV_PAR05+MV_PAR06",1)',"","",25,.f.}) // Loja
If ParamBox(aParamBox,STR0008,@aRet,,,,,,,,.f.) // Filtro
	lRet    := .t.
	aParCEV := aClone(aRet) // Parametros do Filtro
EndIf
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_TIK   ³ Autor ³ Andre Luis Almeida         ³ Data ³ 23/08/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Tik total no ListBox                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_TIK(lTik)
Local ni := 0
For ni := 1 to len(aVetCEV)
	If aVetCEV[ni,8] > 0
		aVetCEV[ni,1] := lTik
	EndIf
Next
oLbCEV:Refresh()
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_FILTRA ³ Autor ³ Andre Luis Almeida        ³ Data ³ 23/08/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Filtra - Levanta Agendas                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_FILTRA(lRefresh)
Local cQuery   := ""
Local cQAlias  := "SQLVC1"
Local lA1_IBGE := ( SA1->(FieldPos("A1_IBGE")) > 0 )
Local lCEVDIA  := ( VAI->(FieldPos("VAI_CEVDIA")) > 0 )  // verdadeiro quando existir o campo VAI_CEVDIA
VAI->(DbSetOrder(4))
VAI->(DbSeek( xFilial("VAI") + __CUSERID ))
aVetCEV := {}
cQuery := "SELECT VC1.VC1_TIPAGE , VC1.VC1_DATAGE , VC1.VC1_CODVEN , VC1.VC1_CODCLI , VC1.VC1_LOJA , VC1.R_E_C_N_O_ AS RECVC1 "
cQuery += ", SA3.A3_NOME , SA1.A1_NOME , SA1.A1_TEL "
If lA1_IBGE
	cQuery += ", VAM.VAM_DDD , VAM.VAM_DESCID AS MUN , VAM.VAM_ESTADO AS EST "
Else
	cQuery += ", SA1.A1_MUN AS MUN , SA1.A1_EST AS EST "
EndIf
cQuery += "FROM "+RetSqlName("VC1")+" VC1 "
cQuery += "LEFT JOIN "+RetSqlName("SA3")+" SA3 ON ( SA3.A3_FILIAL='"+xFilial("SA3")+"' AND SA3.A3_COD=VC1.VC1_CODVEN AND SA3.D_E_L_E_T_=' '  ) "
cQuery += "LEFT JOIN "+RetSqlName("SA1")+" SA1 ON ( SA1.A1_FILIAL='"+xFilial("SA1")+"' AND SA1.A1_COD=VC1.VC1_CODCLI AND SA1.A1_LOJA=VC1.VC1_LOJA AND SA1.D_E_L_E_T_=' '  ) "
If lA1_IBGE
	cQuery += "LEFT JOIN "+RetSqlName("VAM")+" VAM ON ( VAM.VAM_FILIAL='"+xFilial("VAM")+"' AND VAM.VAM_IBGE=SA1.A1_IBGE AND VAM.D_E_L_E_T_=' '  ) "
EndIf
cQuery += "WHERE VC1.VC1_FILIAL='"+xFilial("VC1")+"' AND "
If !Empty(aParCEV[3])
	cQuery += "VC1.VC1_TIPAGE='"+aParCEV[3]+"' AND "
EndIf
If !Empty(aParCEV[4])
	cQuery += "VC1.VC1_CODVEN='"+aParCEV[4]+"' AND "
EndIf
If !Empty(aParCEV[1])
	cQuery += "VC1.VC1_DATAGE>='"+dtos(aParCEV[1])+"' AND "
EndIf
If !Empty(aParCEV[2])
	cQuery += "VC1.VC1_DATAGE<='"+dtos(aParCEV[2])+"' AND "
EndIf
If !Empty(aParCEV[5])
	cQuery += "VC1.VC1_CODCLI='"+aParCEV[5]+"' AND "
EndIf
If !Empty(aParCEV[6])
	cQuery += "VC1.VC1_LOJA='"+aParCEV[6]+"' AND "
EndIf
cQuery += "VC1.VC1_DATVIS=' ' AND VC1.D_E_L_E_T_=' ' "
cQuery += "ORDER BY VC1.VC1_DATAGE , VC1.VC1_TIPAGE , VC1.VC1_CODVEN , VC1.VC1_CODCLI , VC1.VC1_LOJA "
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias , .F., .T. )
Do While !( cQAlias )->( Eof() )
	If lCEVDIA // Desconsiderar Agendas que o usuario nao tem permissao para registrar Visita/Abordagem nesta data! 
		If ( stod(( cQAlias )->( VC1_DATAGE )) + VAI->VAI_CEVDIA ) < dDataBase
			( cQAlias )->( DbSkip() )
			Loop
		EndIf
	EndIf	
	Aadd(aVetCEV,{.f.,( cQAlias )->( VC1_TIPAGE ),;
					Transform(stod(( cQAlias )->( VC1_DATAGE )),"@D"),;
					( cQAlias )->( VC1_CODVEN )+" "+( cQAlias )->( A3_NOME ),;
					( cQAlias )->( VC1_CODCLI )+"-"+( cQAlias )->( VC1_LOJA )+" "+left(( cQAlias )->( A1_NOME ),30),;
					IIf(lA1_IBGE,"("+( cQAlias )->( VAM_DDD )+") ","")+Alltrim(( cQAlias )->( A1_TEL )),;
					Alltrim(left(( cQAlias )->( MUN ),22))+"-"+( cQAlias )->( EST ),;
					( cQAlias )->( RECVC1 )})
	( cQAlias )->( DbSkip() )
EndDo
( cQAlias )->( dbCloseArea() )
If len(aVetCEV) <= 0
	aadd(aVetCEV,{.f.,"","","","","","",0})
EndIf
If lRefresh
	oLbCEV:SetArray(aVetCEV)
	oLbCEV:bLine := { || {	IIf(aVetCEV[oLbCEV:nAt,01],oTik,oNo),;
							aVetCEV[oLbCEV:nAt,02],;
							aVetCEV[oLbCEV:nAt,03],;
							aVetCEV[oLbCEV:nAt,04],;
							aVetCEV[oLbCEV:nAt,05],;
							aVetCEV[oLbCEV:nAt,06] ,;
							aVetCEV[oLbCEV:nAt,07] }}
	oLbCEV:Refresh()
EndIf
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_REGISTRA ³ Autor ³ Andre Luis Almeida      ³ Data ³ 23/08/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Registra a Abordagem por Lote                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_REGISTRA()
Local lRet      := .f.
Local ni        := 0
Local aParamBox := {}
Local aRet      := {} 
Local aRecVEC   := {}
Local nObsOS    := TamSx3("VC1_OCORRE")[1] 
Local lVC1MOTIVO:= ( VC1->(FieldPos("VC1_MOTIVO")) > 0 )
Local lVC1CONPRO:= ( VC1->(FieldPos("VC1_CONPRO")) > 0 )
Private cMotivo := "000010"  //Filtro da consulta do motivo de Encerramento do Contato CEV
Private aMemos  := {{"VC1_OCOMEM","VC1_OCORRE"}}
For ni := 1 to len(aVetCEV)
	If aVetCEV[ni,1] .and. aVetCEV[ni,8] > 0
		aadd(aRecVEC,aVetCEV[ni,8])
    EndIf
Next
If len(aRecVEC) > 0
	INCLUI := .f.
	ALTERA := .t.
	AADD(aParamBox,{1,STR0013,dDataBase,"@D","MV_PAR01<=dDataBase","","",45,.t.}) // Data Abordagem/Visita
	AADD(aParamBox,{1,STR0014," ","@!",'FG_Seek("VCA","MV_PAR02",1)',"VCA","",25,.t.}) // Abordagem
	AADD(aParamBox,{1,STR0015," ","@!",'FG_Seek("VC0","MV_PAR03",1)',"VC0","",25,.t.}) // Tipo de Contato
	AADD(aParamBox,{1,STR0017,"      ","@!",'vazio() .or. FG_Seek("VS0","cMotivo+MV_PAR04",1)',"VS0","",40,.f.}) // Motivo Encerramento
	AADD(aParamBox,{11,STR0016,space(200),"","",.f.}) // Ocorrencia
	If lVC1CONPRO
		AADD(aParamBox,{2,STR0018,"0",{"0="+STR0019,"1="+STR0020},35,"",.t.}) // Contato Produtivo
	EndIf	
	If ParamBox(aParamBox,STR0001,@aRet,,,,,,,,.f.) // CEV - Registro de Abordagem por Lote
		lRet := .t.
		For ni := 1 to len(aRecVEC)
			DbSelectArea("VC1")
			DbGoto(aRecVEC[ni])
			M->VC1_OCORRE := E_MSMM(VC1->VC1_OCOMEM,nObsOS)
			RecLock("VC1",.f.)
				VC1->VC1_DATVIS := aRet[1]
				VC1->VC1_CODABO := aRet[2]
				VC1->VC1_TIPCON := aRet[3]
				If lVC1MOTIVO .and. !Empty(aRet[4])
					VC1->VC1_MOTIVO := aRet[4]
				EndIf
				If lVC1CONPRO
					VC1->VC1_CONPRO := aRet[6]
				EndIf
				If !Empty(M->VC1_OCORRE)
					M->VC1_OCORRE += Chr(13)+Chr(10)+Repl("_",nObsOS)+Chr(13)+Chr(10)
				EndIf
				M->VC1_OCORRE += STR0001+Chr(13)+Chr(10)+Alltrim(aRet[5]) // CEV - Registro de Abordagem por Lote
				MSMM(VC1->VC1_OCOMEM,nObsOS,,&(aMemos[1][2]),1,,,"VC1","VC1_OCOMEM")
			MsUnlock()
		Next
	EndIf
EndIf
Return(lRet)