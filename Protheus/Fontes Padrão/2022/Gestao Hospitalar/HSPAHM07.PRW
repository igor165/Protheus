#INCLUDE "HSPAHM07.ch"
#include "protheus.CH"
#include "colors.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSPAHM07  º Autor ³ Manoel                    ³  21/03/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Devolucao de Produtos Solicitados  (Postos de Enfermagem)  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HSPAHM07()
 Local cIDMaq := HS_NUMID(2, "C:\") // Retorna o Numero de Serie do Volume do Drive C
 Local lLctoDesp := HS_RetLDes(cIDMaq)
 Private bCampo   := { |nCPO| Field(nCPO) }
 Define  FONT oFont NAME "Arial" BOLD
 Private oTik    := LoadBitmap( GetResources(), "LBTIK" )
 Private oNo     := LoadBitmap( GetResources(), "LBNO" )
 Private lGetCCu := .T.
 nReg := 0
 aGets := {}  // matriz que contem os campos que vao receber digitacao na enchoice
 aTela := {}  // matriz que contem os campos que vao aparecer na enchoice
 SetPrvt("wVar")
 Private aTELA[0][0],aGETS[0]
 cSavI := 0
 SetPrvt("AROTINA,CCADASTRO,CALIAS")
 SetPrvt("NOPCE,NOPCG,NUSADO")
 SetPrvt("CTITULO,CALIASENCHOICE,CLINOK,CTUDOK,CFIELDOK")
 SetPrvt("NREG,NOPC")
 
 nOpc    := 3
 nOpcE   := 4
 nOpcG   := 4
 Inclui  := .f.
 Altera  := .t.
 
 aRotina := {{"" , '', 0 , 1},;    && Pesquisar
             {"" , '', 0 , 2},;    && Visualizar
             {"" , '', 0 , 3},;    && Incluir
             {"" , '', 0 , 4, 2},; && Alterar
             {"" , '', 0 , 5, 1} } && Excluir
 
 
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Cria variaveis M->????? da Enchoice                          ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 
 aCpoEnchoice  := {}
 aVoltaCpo     := {}
 Inclui        := .t.
 Altera        := .t.
 DbSelectArea("SX3")
 DbSetOrder(1)
 DbSeek("GBD")
 While !Eof().and.(x3_arquivo=="GBD")
  If X3USO(x3_usado).and.x3_nivel>0
   AADD(aCpoEnchoice,x3_campo)
  Endif

  wVar := "M->"+x3_campo
  &wVar:= CriaVar(x3_campo) // executa x3_relacao
   
  dbSkip()
 End        

 Inclui        := .f.
 Altera        := .t.

 nUsado   :=0
 dbSelectArea("SX3")
 DbSetOrder(1)
 dbSeek("GBE")
 While !Eof().And.(x3_arquivo=="GBE")
  If X3USO(x3_usado).and.x3_nivel>0
   wVar := "M->"+x3_campo
   &wVar:= CriaVar(x3_campo) // executa x3_relacao
  Endif

  dbSkip()
 Enddo

 Inclui := .t.
 Altera := .f.

 cTitulo       := OemToAnsi(STR0001) //"Devolucao de Produtos"
 cAliasEnchoice:= "GBD"
 cAliasGetd    := "GBE"
 cAlias        := "GBE"
 cLinOk        := "AllwaysTrue()"
 cTudOk        := "AllwaysTrue()"
 cFieldOk      := "AllwaysTrue()"
 M->GBD_DATSOL := dDataBase
 M->GBD_REGATE := Space(06)
 M->GBD_NOMPAC := Space(35)
 M->GBD_CODCCU := Space(09)
 M->GBD_DESCCU := Space(30)
 M->GAI_SOLICI := Space(06)
 aLbx          := {{.f.,"","",TRANSFORM(0, "@R 999,999.9999"),TRANSFORM(0, "@R 999,999.9999"),TRANSFORM(0, "@R 999,999.9999") }}
 nOpcaP := 0

 DEFINE MSDIALOG oDlg TITLE cTitulo From 9,0 to 42,80	of oMainWnd   
  @ 015,008 Say OemToAnsi(STR0002) Size 60,0  PIXEL COLOR CLR_BLUE OF oDlg  //"Nro Devolucao"
  @ 015,065 MSGet o01 var M->GBD_NUMDEV Picture "@!" Size  29,9 PIXEL COLOR CLR_BLACK OF oDlg when .f.
   
  @ 029,008 Say OemToAnsi(STR0004) Size 60,0  PIXEL COLOR CLR_BLUE OF oDlg //"Nro Atendimento"
  @ 029,065 MSGet o04 var M->GBD_REGATE Picture "@!" F3 "ZVR" When IIf(!lLctoDesp, GetMV("MV_BLDMMPO") == "1", .T.) Valid HS_VldM07(2) Size  29,9 PIXEL COLOR CLR_BLACK OF oDlg
  @ 029,106 MSGet o05 var M->GBD_NOMPAC Picture "@!" Size  155,9 PIXEL COLOR CLR_BLACK OF oDlg when .f.
        
  @ 043,008 Say OemToAnsi(STR0021) Size 60,0  PIXEL COLOR CLR_BLUE OF oDlg //"Nro. Solicitacao"
  @ 043,065 MSGet o07 var M->GAI_SOLICI Picture "@!" F3 "GAI" When lGetCCu .Or. IIf(!lLctoDesp, GetMV("MV_BLDMMPO") == "0", .F.) Valid HS_VldM07(4) Size  29,9 PIXEL COLOR CLR_BLACK OF oDlg

  @ 057,008 Say OemToAnsi(STR0003) Size 60,0  PIXEL COLOR CLR_BLUE OF oDlg //"Centro de Custo"
  @ 057,065 MSGet o02 var M->GBD_CODCCU Picture "@!" When Empty(M->GAI_SOLICI) .And. (lGetCCu .Or. IIf(!lLctoDesp, GetMV("MV_BLDMMPO") == "0", .F.)) Valid HS_VldM07(1) F3 "CTT" Size  29,9 PIXEL COLOR CLR_BLACK OF oDlg
  @ 057,106 MSGet o03 var M->GBD_DESCCU Picture "@!" Size  155,9 PIXEL COLOR CLR_BLACK OF oDlg when .f.

  @ 071,008 Say OemToAnsi(STR0005) Size 60,0  PIXEL COLOR CLR_BLUE OF oDlg //"Data da Solicitacao"
  @ 071,065 MSGet o06 var M->GBD_DATSOL Picture "@!" Valid HS_VldM07(3) Size  38,9 PIXEL COLOR CLR_BLACK OF oDlg 

  @ 071,106 BUTTON oBtn PROMPT STR0006 SIZE 30,10 OF oDlg PIXEL ACTION FS_Filtro() //"Filtrar"

  @ 88,008 LISTBOX oLbx VAR cLbx FIELDS HEADER " ", ;
										       OemtoAnsi(STR0007),; //"Produto"
										       OemtoAnsi(STR0008),; //"Descricao"
										       OemtoAnsi(STR0009),;	 //"Qtd Lancada"
										       OemtoAnsi(STR0010),;  //"Qtd a Devolver"
										       OemToAnsi(STR0024); //"Qtd Maxima a Devolver"
										COLSIZES 10,29,182,29,29,29;
										SIZE 306,155 OF oDlg PIXEL ON DBLCLICK (nPos:=oLbx:nAt,FS_Marc(),oLbx:Refresh(),oLbx:nAt:=nPos)

  oLbx:SetArray(aLbx)
  oLbx:bLine:={||{if(aLbx[oLbx:nAt,1] == .f.,oNo,oTik),;
                     aLbx[oLbx:nAt,2],;
				     aLbx[oLbx:nAt,3],;				
				     aLbx[oLbx:nAt,4],;				
				     aLbx[oLbx:nAt,5],;
				     aLbx[oLbx:nAt,6]}}  
      
 ACTIVATE MSDIALOG oDlg CENTERED ON INIT (EnchoiceBar(oDlg,{|| oDlg:End(), nOpcaP := FS_VLDM07()},{|| oDlg:End() }))
  
 If nOpcaP == 1
  GrvHSP07()  
  HSPAHR04(GBD->GBD_NUMDEV) // Programa que Imprime Produtos a serem Devolvidos
 Endif

Return
                                    
//////////////////////////
Static Function GrvHSP07()
 Local i := 0
 lGrv := .f.

 For i:=1 to len(aLbx)
  If  Val(aLbx[i,5]) > 0
   lGrv := .t.
   
   If !Empty(M->GBD_REGATE)
    DbSelectArea("GAK")
    DbSetOrder(6)
    DbSeek(xFilial("GAK") + aLbx[i, 7])
   Else                                                                 
    DbSelectArea("GAI")
    DbSetOrder(1)
    DbSeek(xFilial("GAI") + aLbx[i, 7])
   EndIf 
	
   DbSelectArea("GBE")
   RecLock("GBE",.t.)
   HS_GRVCPO("GBE")
   GBE->GBE_FILIAL  := xFilial("GBE")
   GBE->GBE_NUMDEV  := M->GBD_NUMDEV
   GBE->GBE_SOLICI  := IIf(!Empty(M->GBD_REGATE), GAK->GAK_SOLICI, GAI->GAI_SOLICI)
   GBE->GBE_SEQDES  := IIf(!Empty(M->GBD_REGATE), GAK->GAK_SEQDES, GetSXENum("GBE", "GBE_SEQDES",,1))
   GBE->GBE_DATSOL  := M->GBD_DATSOL
   GBE->GBE_PRODEV  := aLbx[i,2]
   GBE->GBE_QTDADV  := Val(aLbx[i,5])
   GBE->GBE_LOGARQ  := cUserName+" - "+strzero(day(dDataBase),2)+"/"+Strzero(month(dDataBase),2)+"/"+str(year(dDataBase),4)+" - "+time()+"h"
   MsUnlock()       
   
   If Empty(M->GBD_REGATE)
    ConfirmSx8()
   EndIf 
  Endif
 Next   

 DbSelectArea("GBD")

 RecLock("GBD",.t.)
 HS_GRVCPO("GBD")
 GBD->GBD_FILIAL := xFilial("GBD")
 ConfirmSX8()
Return(.T.)

/////////////////////////
Function HS_VldM07(cVar)
 Local cSavAlias := alias()

 If cVar == 1 // Centro de Custo
  M->GBD_DESCCU := HS_RDescCC(M->GBD_CODCCU)
  If Empty(AllTrim(M->GBD_DESCCU))
   HS_MsgInf(STR0011,STR0012,STR0001) //"Centro de Custo Inválido!"###"Atenção"###"Devolucao de Produtos"
   Return .f.
  Endif
 ElseIf cVar == 2 // Registro de Atendimento
  If Empty(M->GBD_REGATE) // Se o registro de atendimento for vazio não valida
   lGetCCu := .T. // Permite a edição do centro de custo
   DbSelectArea(cSavAlias)
   Return(.T.)
  Else
   lGetCCu := .F. // Nega a edição do centro de custo
  EndIf  
  
  DbSelectArea("GAD")
  DbSetOrder(1)
  If !DbSeek(xFilial("GAD")+M->GBD_REGATE)
   HS_MsgInf(STR0013,STR0012,STR0001) //"Registro de Atendimento Inválido!"###"Atenção"###"Devolucao de Produtos"
   DbSelectArea(cSavAlias)
   Return(.F.)
  Endif
   
  if GAD->GAD_DATFAT <> cTod("")
   cDatFat := Subs(Dtos(GAD->GAD_DATFAT),7,2) + "/" + Subs(Dtos(GAD->GAD_DATFAT),5,2) + "/" + Subs(Dtos(GAD->GAD_DATFAT),1,4)
   HS_MsgInf(STR0014 + cDatFat + STR0015,STR0012,STR0001) //"Esta conta foi Faturada no dia "###". Não é permitida a Devolução!"###"Atenção"###"Devolucao de Produtos"
   DbSelectArea(cSavAlias)
   Return(.F.)
  Endif
	
  if GAD->GAD_DATFEC # cTod("")
   cDatFec := Subs(Dtos(GAD->GAD_DATFEC),7,2) + "/" + Subs(Dtos(GAD->GAD_DATFEC),5,2) + "/" + Subs(Dtos(GAD->GAD_DATFEC),1,4)
   HS_MsgInf(STR0016 + cDatFec + STR0015,STR0012,STR0001) //"Esta conta já foi Fechada no dia "###". Não é permitida a Devolução!"###"Atenção"###"Devolucao de Produtos"
   DbSelectArea(cSavAlias)
   Return(.F.)
  Endif

  M->GBD_NOMPAC := GAD->GAD_NOME     
  M->GBD_CODCCU := GAD->GAD_CCUINT
  M->GBD_DESCCU := HS_RDescCC(M->GBD_CODCCU)
 ElseIf cVar == 3 // Data da Solicitacao   
  If M->GBD_DATSOL > dDataBase
   HS_MsgInf(STR0017,STR0012,STR0001) //"Data Inválida para Devolução!"###"Atenção"###"Devolucao de Produtos"
   DbSelectArea(cSavAlias)
   Return(.F.)
  Endif
 ElseIf cVar == 4 // Nro. Da Solicitacao
  If !Empty(M->GAI_SOLICI)
   If !HS_SeekRet("GAI","M->GAI_SOLICI",1,.f.)
    HS_MsgInf(STR0022, STR0012, STR0001) //"Solicitacao invalida"###"Atenção"###"Devolucao de Produtos"
    Return .f.
   Endif
   M->GBD_CODCCU := GAI->GAI_CODCCU
   M->GBD_DESCCU := HS_RDescCC(M->GBD_CODCCU)
   M->GBD_DATSOL := GAI->GAI_DATSOL
  EndIf 
 Endif        
 DbSelectArea(cSavAlias)
Return(.T.)
  
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FS_Marc        ³ Autor ³  Manoel          ³ Data   26/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Marca no ListBox do Filtro                                 ³±±
±±³          ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS_Marc()
 nQtdade := 0
 nOpca1  := 0
									 	 	  
 DEFINE MSDIALOG oDlgx TITLE OemToAnsi("") From 9,1 to 14,55 of oMainWnd
  @ 017,004 Say OemToAnsi(STR0018) of Odlgx Pixel  //"Quantidade"
  //@ 017,092 MSGET oQtdade VAR nQtdade VALID FS_ValQtd() PICTURE "@!" F3 "GBJ" SIZE 43,4 OF oDlgx PIXEL COLOR CLR_BLACK
  @ 017,092 MSGET oQtdade VAR nQtdade VALID FS_ValQtd() PICTURE "@E 999,999.9999" SIZE 43,4 OF oDlgx PIXEL COLOR CLR_BLACK
 ACTIVATE MSDIALOG oDlgx CENTERED ON INIT EnchoiceBar(oDlgx,{||nOpca1 := 1,oDlgx:End()},{||nOpca1 := 0,oDlgx:End() })	
											 											 
 If nOpca1 == 1                
  aLbx[oLbx:nAt,5] := TransForm(nQtdade, "@R 999,999.9999")
 Endif
	 	
 If Val(aLbx[oLbx:nAt,5]) <> 0
  aLbx[oLbx:nAt,1] := .t.
 Else
  aLbx[oLbx:nAt,1] := .f.
 Endif

 oLbx:refresh()
Return

///////////////////////////////
// Valida Quantidade Devolvida
///////////////////////////////
Static Function FS_ValQtd()    
 If nQtdade > Val(aLbx[oLbx:nAt,4])
  HS_MsgInf(STR0019,STR0012,STR0027) //"Quantidade Devolvida deve ser MENOR ou IGUAL a Quantidade Lançada!"###"Atenção" //"Valida Quantidade Devolvida"
  Return .f.
 Elseif nQtdade > Val(aLbx[oLbx:nAt,6]) .or. Val(aLbx[oLbx:nAt,6]) < 0
  HS_MsgInf(STR0025,STR0012,STR0027) //"Quantidade Devolvida deve ser MENOR ou IGUAL a Quantidade Maxima a Devolver"###"Atenção" //"Valida Quantidade Devolvida"
  Return .f.
 Endif
Return .t.

//////////////////////////////////////////////////////////
// Seleciona registros a partir dos parametros informados
//////////////////////////////////////////////////////////
Static Function FS_Filtro()
 Local cSavAlias 		:= alias(), lRet := .T.
	Local nQtdeMaxPer := 0
	Local nQtdeEmp				:= 0
	Local cIndGBE 				:= ""
	Local cKeyGBE 				:= ""
	Local nIndexGBE			:= 0 

 aLbx := {}    
  
	If Empty(M->GBD_REGATE)  // cria indice temporario para o GBE caso nao exista registro de atendimento
		cIndGBE := CriaTrab(Nil,.F.)
		cKeyGBE	:= "GBE_FILIAL+GBE_SOLICI+DtoS(GBE_DATSOL)"

		IndRegua("GBE", cIndGBE, cKeyGBE,,, STR0026) //"Aguarde..."
		nIndexGBE := RetIndex("GBE")
		DbSelectArea("GBE")

		#IFNDEF TOP
			DbSetIndex(cIndGBE+OrdBagExt())
		#ENDIF
		DbSetOrder(nIndexGBE+1)
		DbGoTop()
	Endif

 If !Empty(M->GBD_REGATE)
  DbSelectArea("GAK")                      
  DbSetOrder(1)

  If DbSeek(xFilial("GAK") + M->GBD_REGATE + "0" + Dtos(M->GBD_DATSOL)) .Or. ;
     DbSeek(xFilial("GAK") + M->GBD_REGATE + "1" + Dtos(M->GBD_DATSOL))
   
   DbSeek(xFilial("GAK") + M->GBD_REGATE + "0" + Dtos(M->GBD_DATSOL))
   While !eof() .And. GAK->GAK_FILIAL + GAK->GAK_REGATE + GAK->GAK_FLGDCI + Dtos(GAK->GAK_DATMAT) == ;
                      xFilial("GAK")  + M->GBD_REGATE   + "0"             + Dtos(M->GBD_DATSOL)
  
    If !GAK->GAK_GLOMAT $ "0/2" //.or. EMPTY(GAK->GAK_SOLICI)
     DbSkip()
     Loop
    Endif
                                                                     
    DbSelectArea("SB1")  
    DbSetOrder(1)
    DbSeek(xFilial("SB1") + GAK->GAK_CODMAT)
                       
  		GAJ->(DbSetOrder(3))
  		If (GAJ->(DbSeek(xFilial("GAJ") + GAK->GAK_SEQDES)) .and. !Empty(GAK->GAK_SEQDES))
					GBE->(DbSetOrder(1))
  			GBE->(DbSeek(xFilial("GBE") + GAK->GAK_SEQDES))
 
  			Do While GBE->(!Eof()) .and. GBE->GBE_FILIAL + GBE->GBE_SEQDES == xFilial("GBE") + GAK->GAK_SEQDES;
  																											.and. GBE->GBE_DATSOL == M->GBD_DATSOL

						nQtdeEmp += (GBE->GBE_QTDADV - GBE->GBE_QTDDEV)
						GBE->(DbSkip())
  			Enddo
  			
  			nQtdeMaxPer := (GAJ->GAJ_QTDATE - GAJ->GAJ_DEVPOS) - nQtdeEmp

					aAdd(aLbx, {.F., GAK->GAK_CODMAT, SB1->B1_DESC, TransForm(GAK->GAK_QTDMAT, "@R 999,999.9999"), TransForm(0, "@R 999,999.9999"), TransForm(nQtdeMaxPer, "@R 999,999.9999"), GAK->GAK_SEQDES})
				
					nQtdeMaxPer := 0
					nQtdeEmp 			:= 0

				Endif
                       
    DbSelectArea("GAK")
    DbSkip()
   Enddo
    
   DbSeek(xFilial("GAK") + M->GBD_REGATE + "1" + Dtos(M->GBD_DATSOL))
   While !Eof() .And. GAK->GAK_FILIAL + GAK->GAK_REGATE + GAK->GAK_FLGDCI + Dtos(GAK->GAK_DATMAT) == ;
                      xFilial("GAK")  + M->GBD_REGATE   + "1"             + Dtos(M->GBD_DATSOL)
 	
    If !GAK->GAK_GLOMAT $ "0/2" //.Or. EMPTY(GAK->GAK_SOLICI)
     DbSkip()
     Loop
    Endif
                                                                        
    DbSelectArea("SB1")
    DbSetOrder(1)
    DbSeek(xFilial("SB1") + GAK->GAK_CODMAT)
 	                      
  		GAJ->(DbSetOrder(3))
  		If (GAJ->(DbSeek(xFilial("GAJ") + GAK->GAK_SEQDES)) .and. !Empty(GAK->GAK_SEQDES))
					GBE->(DbSetOrder(1))
  			GBE->(DbSeek(xFilial("GBE") + GAK->GAK_SEQDES))

  			Do While GBE->(!Eof()) .and. GBE->GBE_FILIAL + GBE->GBE_SEQDES == xFilial("GBE") + GAK->GAK_SEQDES ;
  																											.and. GBE->GBE_DATSOL == M->GBD_DATSOL

						nQtdeEmp += (GBE->GBE_QTDADV - GBE->GBE_QTDDEV)
						GBE->(DbSkip())
  			Enddo
  			
  			nQtdeMaxPer := (GAJ->GAJ_QTDATE - GAJ->GAJ_DEVPOS) - nQtdeEmp
  			
  			aAdd(aLbx, {.F., GAK->GAK_CODMAT, SB1->B1_DESC, TransForm(GAK->GAK_QTDMAT, "@R 999,999.9999"), TransForm(0, "@R 999,999.9999"), TransForm(nQtdeMaxPer, "@R 999,999.9999"), GAK->GAK_SEQDES})
					
					nQtdeMaxPer := 0
  			nQtdeEmp				:= 0

  		Endif
 	                      
    DbSelectArea("GAK")
    DbSkip()
   Enddo
  Endif
 Else
  DbSelectArea("GAJ") 
  DbSetOrder(6)
  If DbSeek(xFilial("GAJ") + M->GBD_CODCCU + DToS(M->GBD_DATSOL))
   While !Eof() .And. GAJ->GAJ_CODCCU == M->GBD_CODCCU .And. GAJ->GAJ_DATSOL == M->GBD_DATSOL      
    If !Empty(M->GAI_SOLICI) .And. GAJ->GAJ_SOLICI # M->GAI_SOLICI
     DbSkip()
     Loop
    EndIf
     
    DbSelectArea("GAI")
    DbSetOrder(1)
    DbSeek(xFilial("GAI") + GAJ->GAJ_SOLICI)
    
    DbSelectArea("SB1")
    DbSetOrder(1)
    DbSeek(xFilial("SB1") + GAJ->GAJ_PROSOL)
    
    DbSelectArea("GAJ")
    
    If GAI->GAI_REQUIS # "2" .Or. (GAJ->GAJ_QTDATE - GAJ->GAJ_ATEPOS) <= 0
     DbSkip()
     Loop
    EndIf                                   
    
  		GBE->(DbSeek(xFilial("GBE") + GAJ->GAJ_SOLICI))

  		Do While GBE->(!Eof()) .and. GBE->GBE_FILIAL + GBE->GBE_SOLICI == xFilial("GBE") + GAJ->GAJ_SOLICI ;
  																											.and. GBE->GBE_DATSOL == M->GBD_DATSOL

					nQtdeEmp += (GBE->GBE_QTDADV - GBE->GBE_QTDDEV)

					GBE->(DbSkip())
 			Enddo
  			
  		nQtdeMaxPer := (GAJ->GAJ_QTDATE - GAJ->GAJ_DEVPOS) - nQtdeEmp

    aAdd(aLbx, {.F., GAJ->GAJ_PROSOL, SB1->B1_DESC, TransForm(GAJ->GAJ_QTDATE - GAJ->GAJ_ATEPOS, "@R 999,999.9999"), TransForm(0, "@R 999,999.9999"), TransForm(nQtdeMaxPer, "@R 999,999.9999"), GAJ->GAJ_SOLICI})

				nQtdeMaxPer := 0
				nQtdeEmp    := 0

    DbSkip()
   End
  EndIf 
 EndIf 

 If Len(aLbx) == 0
  If !Empty(M->GBD_REGATE)
   HS_MsgInf(STR0020,STR0012,STR0028) //"Não existem ítens lançados para este Paciente nesta Data!"###"Atenção" //"Selecao de registros"
  Else                    
   HS_MsgInf(STR0023,STR0012,STR0028) //"Não existem ítens lançados para este centro de custo nesta Data!"###"Atenção" //"Selecao de registros"
  EndIf
  lRet := .F.
  aLbx := {{.f.,"","",TRANSFORM(0, "@R 999,999.9999"),TRANSFORM(0, "@R 999,999.9999"),TRANSFORM(0, "@R 999,999.9999")}}
 EndIf
 
 oLbx:SetArray(aLbx)
 oLbx:bLine:={||{if(aLbx[oLbx:nAt,1] == .f.,oNo,oTik),;
                    aLbx[oLbx:nAt,2],;
                    aLbx[oLbx:nAt,3],;				
                    aLbx[oLbx:nAt,4],;				
                    aLbx[oLbx:nAt,5],;
                    aLbx[oLbx:nAt,6]}}
 oLbx:Refresh()


	If File(cIndGBE+OrdBagExt())  // Apaga indice temporario
		DbSelectArea("GBE")
		DbSetOrder(1)
		RetIndex("GBE")     
		DbSetOrder(GBE->(IndexOrd()))
		Set Filter to
		fErase(cIndGBE+OrdBagExt())
	Endif


 DbSelectArea(cSavAlias)
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_VLDM07 ³ Autor ³ Robson Ramiro A. Olive³ Data ³ 20.10.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Valida rotina para gravacao                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FS_VLDM07                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Void                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ HSP                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function FS_VLDM07

Local nRetorno := 0
Local nCont				:= 0

For nCont := 1 to Len(aLbx)
  If  Val(aLbx[nCont,5]) > 0  // Garante que ao menos 1 item tenha dados
			nRetorno := 1
  Endif
Next nCont

Return nRetorno
