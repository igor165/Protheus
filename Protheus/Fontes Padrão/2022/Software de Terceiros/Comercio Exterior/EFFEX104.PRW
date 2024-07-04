#INCLUDE "AVERAGE.CH"
#include "tbiconn.ch"

/*
Programa        : EFFEX103.PRW
Objetivo        : Cancelamento de lançamentos da Contabilização.
Autor           : Alessandro Alves Ferreira
Data/Hora       : 21/10/2013
*/
Function EFFEX104()
Private aF3Generico := {}
Private cQuery := "Select DISTINCT EF3_CONTRA, EF3_DT_EVE, EF3_CODEVE, EF3_NRLOTE from "+RetSQLName("EF3")+" where D_E_L_E_T_ = '' AND EF3_NRLOTE <> '' "

aAdd(aF3Generico,"WKF3QRY")//Alias
aAdd(aF3Generico,{|| EasyWkQuery(ChangeQuery(cQuery+if(!Empty(MV_PAR01)," AND EF3_DT_EVE >= '"+DTos(MV_PAR01)+"' ","")+if(!Empty(MV_PAR02)," AND EF3_DT_EVE <= '"+DTos(MV_PAR02)+"' ","")),"WKF3QRY",{"EF3_CONTRA","EF3_NRLOTE"}) })//bInicio
aAdd(aF3Generico,xFilial("EF3"))//cFilial
aAdd(aF3Generico,.F.)//lChange
aAdd(aF3Generico,"")//cSeekCapa
aAdd(aF3Generico,"")//cFiltro
aAdd(aF3Generico,{|| M->MV_PAR03 := WKF3QRY->EF3_NRLOTE})//bReturn
aAdd(aF3Generico,"Lotes de contratos contabilizados")//cTitulo
aAdd(aF3Generico,{AvSX3("EF3_CONTRA",AV_TITULO),AvSX3("EF3_NRLOTE",AV_TITULO)})//aORDEM
aAdd(aF3Generico,NIL)//Colunas
aAdd(aF3Generico,{|| WKF3QRY->(E_ERASEARQ(WKF3QRY->(dbInfo(10)))) })//bFinal

Begin Sequence

   If !Pergunte("EX104",.T.)
      Break
   Endif

   If !Empty(MV_PAR03)
   
      If EX104CanLote(MV_PAR03, MV_PAR04)
	     If !(MV_PAR04==1)
            MsgInfo("Lote "+MV_PAR03+" cancelado com sucesso no Easy Financing Control. É recomendado o cancelamento do lote no ERP.")
		 Else
		    MsgInfo("Lote "+MV_PAR03+" cancelado e integrado com sucesso no ERP.")
		 EndIf
      EndIf
   
   EndIf

End Sequence

Return Nil

Static Function EX104CanLote(cLote)
Local lRet := .T.
Local cQuery, i
Local aCpos := {{"EF3_NRLOTE"},{"EF3_RELACA"},{"EF3_NR_CON"}}
Local aContra, aChaveEF1 := {}
Local nPos
Local j

For i := 1 To Len(aCpos)
   aAdd(aCpos[i],CriaVar(aCpos[i][1],.F.))
Next i

If Select("QUERY") > 0
   QUERY->(dbCloseArea())
EndIf

cQuery := "Select R_E_C_N_O_ AS RECNO"
cQuery += "From "+RetSQLName("EF3")+" EF3 "
cQuery += "Where D_E_L_E_T_ = '' AND EF3_NRLOTE = '"+cLote+"' "
//AAF 04/09/2015 - Adicionado filtro para o periodo, pois o Logix permite o mesmo numero de lote em periodos contabeis diferentes e não pode mandar os lançamentos fora do periodo.
cQuery += if(!Empty(MV_PAR01)," AND EF3_DT_EVE >= '"+DTos(MV_PAR01)+"' ","")+if(!Empty(MV_PAR02)," AND EF3_DT_EVE <= '"+DTos(MV_PAR02)+"' ","")

cQuery := ChangeQuery(cQuery)
dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery), "QUERY", .F.) 

If QUERY->(Eof())
   EasyHelp("Não há registros contabilizados com o lote "+cLote,"Atenção")
   lRet := .F.
ElseIf !(MV_PAR04==1)
   Begin Transaction
   
      Do While !QUERY->(Eof())
         
		 EF3->(dbGoTo(QUERY->RECNO))
		 If EF3->(!Eof())
		 
		    If aScan(aChaveEF1,{|X| X[1]+X[2]+X[3]+X[4]+X[5]+X[6]==EF3->EF3_FILIAL+EF3->EF3_TPMODU+EF3->EF3_CONTRA+EF3->EF3_BAN_FI+EF3->EF3_PRACA+EF3->EF3_SEQCNT}) == 0
			   aAdd(aChaveEF1,{EF3->EF3_FILIAL,EF3->EF3_TPMODU,EF3->EF3_CONTRA,EF3->EF3_BAN_FI,EF3->EF3_PRACA,EF3->EF3_SEQCNT})
			EndIf
					 
		    EF3->(RecLock("EF3",.F.))
			
			For i = 1 To Len(aCpos)
			   If EF3->(FieldPos(aCpos[i][1])) > 0
			      EF3->(FieldPut(FieldPos(aCpos[i][1]),aCpos[i][2]))
			   EndIf
			Next i
			
			EF3->(MsUnLock())
		 EndIf
         QUERY->(dbSkip())
      EndDo
   
   End Transaction
   QUERY->(dbCloseArea())
Else
   aContra := {}
   Do While !QUERY->(Eof())
      EF3->(dbGoTo(QUERY->RECNO))
	  If EF3->(!Eof())
		 If aScan(aChaveEF1,{|X| X[1]+X[2]+X[3]+X[4]+X[5]+X[6]==EF3->EF3_FILIAL+EF3->EF3_TPMODU+EF3->EF3_CONTRA+EF3->EF3_BAN_FI+EF3->EF3_PRACA+EF3->EF3_SEQCNT}) == 0
		    aAdd(aChaveEF1,{EF3->EF3_FILIAL,EF3->EF3_TPMODU,EF3->EF3_CONTRA,EF3->EF3_BAN_FI,EF3->EF3_PRACA,EF3->EF3_SEQCNT})
		 EndIf

	     If (nPos := aScan(aContra,{|X| X[1] == EF3->EF3_NRLOTE})) == 0
		    aAdd(aContra,{EF3->EF3_NRLOTE,{}})
		    nPos := Len(aContra)
		 EndIf
	     aAdd(aContra[nPos][2],{EF3->EF3_NR_CON,EF3->(RecNo())})
	  EndIf
      
      QUERY->(dbSkip())
   EndDo
   QUERY->(dbCloseArea())
   
   For i := 1 To Len(aContra) //De acordo com a query
      aSort(aContra[i][2],,,{|X,Y| X[1] < Y[1]})
	  
	  Private aEF3 := {}
	  For j := 1 To Len(aContra[i][2])
	     aAdd(aEF3,aContra[i][2][j][2])
	  Next j
	  
	  EF3->(dbGoTo(aEF3[1]))
	  
	  EF1->( DbSetOrder(1) ) //EF3_FILIAL+EF3_TPMODU+EF3_CONTRA+EF3_BAN_FI+EF3_PRACA+EF3_SEQCNT+EF3_CODEVE+EF3_PARC+EF3_INVOIC+EF3_INVIMP+EF3_LINHA
	  If EF1->( DbSeek( xFilial("EF3")+EF3->EF3_TPMODU+EF3->EF3_CONTRA+EF3->EF3_BAN_FI+EF3->EF3_PRACA+EF3->EF3_SEQCNT ) )
	  
	     //AAF 23/07/2015 - Garante que as tabelas do EasyLink estejam atualizadas.
	     //EasyLinkAtu() //LRS - 20/10/2017 - Function transferida para o Avupdate02
		 
         lRet:= AvStAction("090")
	  EndIf
   Next i
EndIf

For i := 1 To Len(aChaveEF1)
   cQuery := "Select Max(EF3_DT_EVE) AS DTCTB "
   cQuery += "From "+RetSQLName("EF3")+" EF3 "
   cQuery += "Where D_E_L_E_T_ = ' ' AND EF3_NRLOTE <> ' ' AND "
   cQuery += "EF3_FILIAL = '"+aChaveEF1[i][1]+"' AND EF3_TPMODU = '"+aChaveEF1[i][2]+"' AND EF3_CONTRA = '"+aChaveEF1[i][3]+"' AND "
   cQuery += "EF3_BAN_FI = '"+aChaveEF1[i][4]+"' AND EF3_PRACA = '"+aChaveEF1[i][5]+"' AND EF3_SEQCNT = '"+aChaveEF1[i][6]+"' "
   cQuery := ChangeQuery(cQuery)
   dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery), "QUERY", .F.)
   
   TCSetField("QUERY", "DTCTB", "D", 8, 0 )
   
   EF1->( dbSetOrder(1) ) //EF3_FILIAL+EF3_TPMODU+EF3_CONTRA+EF3_BAN_FI+EF3_PRACA+EF3_SEQCNT+EF3_CODEVE+EF3_PARC+EF3_INVOIC+EF3_INVIMP+EF3_LINHA
   If EF1->( dbSeek( aChaveEF1[i][1]+aChaveEF1[i][2]+aChaveEF1[i][3]+aChaveEF1[i][4]+aChaveEF1[i][5]+aChaveEF1[i][6] ) )
      RecLock("EF1",.F.)
	  EF1->EF1_DT_CTB := QUERY->DTCTB
	  EF1->(MsUnLock())
   EndIf
   
   QUERY->(dbCloseArea())
Next i

Return lRet
