#INCLUDE "PROTHEUS.CH"
Static lProc := .T.
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CT2SeqIDX³ Autor ³ Simone Mie Sato       ³ Data ³ 13.07.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gravacao do campo CT2_SEQIDX para lanc. c/chave duplicada. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ct2SeqIDX                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaCtb                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ct2SeqIDX()

Local cChaveAnt	:= ""

Local nSeqIDX	:= 0 
#IFDEF TOP
	Local cProcName
	Local cQuery     := ""	
	Local iRet       := 0
	Local lRet       := .T.
	Local aDataBase  :={}
	Local cTDataBase := ""
	Local nPos       := 0 
	Local cProc      := "SEQIDX" , cProc1
	Private aResult := {}
#ENDIF
 						 
dbSelectArea("CT2")
dbSetOrder(1)
dbGoTop()
MsSeek(xFilial("CT2"))            

UpdSet01(LastRec())               
#IFDEF TOP
	If TcSrvType() != "AS/400"
		aadd(aDatabase,{"MSSQL" })
		aadd(aDatabase,{"MSSQL7" })
		aadd(aDatabase,{"ORACLE" })
		aadd(aDatabase,{"DB2" })
		aadd(aDatabase,{"SYBASE" })
		aadd(aDatabase,{"INFORMIX" })
		If Trim(Upper(TcSrvType())) = "ISERIES"
			// Top 4 para AS400, instala procedures = DB2
			aadd(aDatabase,{"DB2/400"})
		EndIf
		cTDataBase = Trim(Upper(TcGetDb()))
		nPos:= Ascan( aDataBase, {|z| z[1] == cTDataBase })
		
		If nPos = 0                           // bcos q instalam procedure
			lRet := .f.
		EndIf
		If lRet
			/* Cria e instala a procedure MSSTRZERO com outro nome */ 
			cProc1 := CriaTrab(,.F.)
			cProc1 := cProc1
			cQuery := ProcSTRZERO(cProc1)
			If TCSPExist( cProc1+"_"+cEmpAnt)
				iRet := TcSqlExec("DROP PROCEDURE "+cProc1+"_"+cEmpAnt)
				If iRet <> 0
					MsgAlert("Erro na exclusão da procedure "+cProc1+"_"+cEmpAnt )
					lRet := .F.
				EndIf
			EndIf
			If lRet
				iRet := TcSqlExec(cQuery)
				If iRet < 0
					MsgAlert("Erro na criação da procedure: "+cProc1+"_"+cEmpAnt )
					lRet := .F.
				EndIf
			EndIf
		EndIf
		If lRet        
			/* Cria e instala a procedure que atualiza CT2_SEQIDX */ 
			cQuery:= ""
			cQuery := SeqIdxProc(cProc1)
			If TCSPExist( cProc+"_"+cEmpAnt )
				iRet := TcSqlExec("DROP PROCEDURE "+cProc+"_"+cEmpAnt)
				If iRet <> 0
					MsgAlert("Erro na exclusão da procedure: "+cProc+"_"+cEmpAnt)
					lRet := .F.
				EndIf
			EndIf
			/* Cria a procedure que atualiza CT2_SEQIDX */ 
            iRet := TcSqlExec(cQuery)
			If iRet < 0
				MsgAlert("Erro na criação da procedure: "+cProc+"_"+cEmpAnt)
				lRet := .F.
			else
				MsgRun( "Aguarde ... " +"Atualizando... " , "Atualizando CT2_SEQIDX" , {|| aResult := TCSPEXEC( xProcedures(cProc))})
				/* Exclui a procedure que atualiza CT2_SEQIDX */
				iRet := TcSqlExec("DROP PROCEDURE "+cProc+"_"+cEmpAnt)
				If iRet <> 0
					MsgAlert("Erro na exclusão da procedure: "+cProc+"_"+cEmpAnt+". Excluir manualmente do banco de dados")
				EndIf
				/* Exclui a procedure msstrzero */ 
				iRet := TcSqlExec("DROP PROCEDURE "+cProc1+"_"+cEmpAnt)
				If iRet <> 0
					MsgAlert("Erro na exclusão da procedure: "+cProc1+"_"+cEmpAnt+". Excluir manualmente do banco de dados")
				EndIf
	  		EndIf
	  	EndIf
	Endif
	If TcSrvType() = "AS/400" .or. (!lRet) .Or. aResult[1] != '1'
#ENDIF
If lProc == Nil .Or. lProc                                                     
	//Atualizar o campo CT2_SEQIDX	=> C - 5
	While !Eof() .And. CT2->CT2_FILIAL == xFilial("CT2")            
	

		If cChaveAnt <>  CT2->(CT2_FILIAL+DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_LINHA+CT2_TPSALD+CT2_EMPORI+CT2_FILORI+CT2_MOEDLC)
			nSeqIdx	:= 1
		EndIf               
	
		If cChaveAnt == CT2->(CT2_FILIAL+DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_LINHA+CT2_TPSALD+CT2_EMPORI+CT2_FILORI+CT2_MOEDLC)			
			Reclock("CT2",.F.)	
			CT2->CT2_SEQIDX	:= StrZero(nSeqIdx,5)	
			MsUnlock()	     
			nSeqIdx++ 				
		EndIf	        
	
		cChaveAnt := CT2->(CT2_FILIAL+DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_LINHA+CT2_TPSALD+CT2_EMPORI+CT2_FILORI+CT2_MOEDLC)					
		dbSelectArea("CT2")
		dbSkip()
	End          
Endif
If Empty(xFilial('CT2'))
	lProc := .F.
Endif	
#IFDEF TOP
	Endif
#ENDIF
Return .T.
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³SeqIDXProc³ Autor ³ Alice Y Yamamoto      ³ Data ³ 15.01.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Procedure p/ a gravacao do campo CT2_SEQIDX ch  duplicada. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ SeqIDxProc                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaCtb                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cProc1-procedure utilizada (MSSTRZERO)                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function SeqIdxProc(cProc1)
Local cQuery := ""
Local nTam   := 0
Local cTipo  := ""
Local nPos   := 0
Local aCampos   := CT2->(DbStruct())

cQuery := "Create Procedure SEQIDX"+"_"+cEmpAnt+CRLF
cQuery += "("+CRLF   
cQuery += "   @OUT_RESULT char( 01 ) OutPut"+CRLF
cQuery += ")"+CRLF
cQuery += "as"+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_FILIAL" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
cQuery += "Declare @cCT2_FILIAL "+cTipo+CRLF
cQuery += "Declare @cCT2_DATA   Char( 08 )"+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_LOTE" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
cQuery += "Declare @cCT2_LOTE   "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_SBLOTE" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
cQuery += "Declare @cCT2_SBLOTE "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_DOC" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
cQuery += "Declare @cCT2_DOC    "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_LINHA" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
cQuery += "Declare @cCT2_LINHA  "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_TPSALD" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
cQuery += "Declare @cCT2_TPSALD "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_EMPORI" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
cQuery += "Declare @cCT2_EMPORI "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_FILORI" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
cQuery += "Declare @cCT2_FILORI "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_MOEDLC" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
cQuery += "Declare @cCT2_MOEDLC "+cTipo+CRLF
cQuery += "Declare @iSeqIdx     integer"+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_SEQIDX" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
cQuery += "Declare @cSeqIdx     "+cTipo+CRLF
cQuery += "Declare @iRecno      integer"+CRLF

cQuery += "begin"+CRLF
cQuery += "   Select @OUT_RESULT = '0'"+CRLF
cQuery += "   Select @iSeqIdx   = 0"+CRLF
cQuery += "   Select @cSeqIdx   = ' '"+CRLF
cQuery += "   Select @iRecno    = 0"+CRLF
   
cQuery += "   Declare CUR_SEQIDX insensitive cursor for"+CRLF
cQuery += "    Select CT2_FILIAL, CT2_DATA, CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_LINHA, CT2_TPSALD, CT2_EMPORI, CT2_FILORI, CT2_MOEDLC"+CRLF
cQuery += "      from "+RetSqlName("CT2")+CRLF
cQuery += "      Where D_E_L_E_T_= ' '"+CRLF
cQuery += "   group by CT2_FILIAL, CT2_DATA, CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_LINHA, CT2_TPSALD, CT2_EMPORI, CT2_FILORI, CT2_MOEDLC"+CRLF
cQuery += "   having count(*) > 1"+CRLF
cQuery += "   for read only"+CRLF
cQuery += "   Open CUR_SEQIDX"+CRLF
cQuery += "   Fetch CUR_SEQIDX into @cCT2_FILIAL, @cCT2_DATA, @cCT2_LOTE, @cCT2_SBLOTE, @cCT2_DOC, @cCT2_LINHA, @cCT2_TPSALD, @cCT2_EMPORI, @cCT2_FILORI, @cCT2_MOEDLC"+CRLF
   
cQuery += "   While (@@Fetch_status = 0 ) begin"+CRLF
cQuery += "      Declare CUR1_SEQIDX insensitive cursor for"+CRLF
cQuery += "       Select R_E_C_N_O_"+CRLF
cQuery += "         from "+RetSqlName("CT2")+CRLF
cQuery += "        Where D_E_L_E_T_ = ' '"+CRLF
cQuery += "          AND CT2_FILIAL = @cCT2_FILIAL"+CRLF
cQuery += "          AND CT2_DATA   = @cCT2_DATA"+CRLF
cQuery += "          AND CT2_LOTE   = @cCT2_LOTE"+CRLF
cQuery += "          AND CT2_SBLOTE = @cCT2_SBLOTE"+CRLF
cQuery += "          AND CT2_DOC    = @cCT2_DOC"+CRLF
cQuery += "          AND CT2_LINHA  = @cCT2_LINHA"+CRLF
cQuery += "          AND CT2_TPSALD = @cCT2_TPSALD"+CRLF
cQuery += "          AND CT2_EMPORI = @cCT2_EMPORI"+CRLF
cQuery += "          AND CT2_FILORI = @cCT2_FILORI"+CRLF
cQuery += "          AND CT2_MOEDLC = @cCT2_MOEDLC"+CRLF
cQuery += "      Order by R_E_C_N_O_"+CRLF
cQuery += "      for read only"+CRLF
cQuery += "      Open CUR1_SEQIDX"+CRLF
cQuery += "      Fetch CUR1_SEQIDX into @iRecno"+CRLF
cQuery += "      Begin tran "+CRLF
cQuery += "      While (@@Fetch_status = 0 ) begin"+CRLF
cQuery += "         If @iSeqIdx = 0 begin"+CRLF
cQuery += "            select @cSeqIdx = ' '"+CRLF
cQuery += "         end else begin"+CRLF
cQuery += "            Exec "+cProc1+"_"+cEmpAnt+" @iSeqIdx, 5, @cSeqIdx OutPut"+CRLF
cQuery += "         End"+CRLF     
         
cQuery += "         UpDate "+RetSqlName("CT2")+CRLF
cQuery += "            Set CT2_SEQIDX = @cSeqIdx"+CRLF
cQuery += "          Where R_E_C_N_O_ = @iRecno"+CRLF
         
cQuery += "         select @iSeqIdx = @iSeqIdx + 1"+CRLF
cQuery += "         Fetch CUR1_SEQIDX into @iRecno"+CRLF
cQuery += "      End"+CRLF
cQuery += "      Commit tran"+CRLF
cQuery += "      Close CUR1_SEQIDX"+CRLF
cQuery += "      Deallocate CUR1_SEQIDX"+CRLF
      
cQuery += "      select @iSeqIdx = 0"+CRLF
If Upper(Trim(TcGetDb()))=="DB2" .or. Upper(Trim(TcGetDb()))=="DB2/400"
	cQuery += "      SELECT @fim_CUR = 0"+CRLF
EndIf
cQuery += "      Fetch CUR_SEQIDX into @cCT2_FILIAL, @cCT2_DATA, @cCT2_LOTE, @cCT2_SBLOTE, @cCT2_DOC, @cCT2_LINHA, @cCT2_TPSALD, @cCT2_EMPORI, @cCT2_FILORI, @cCT2_MOEDLC"+CRLF
cQuery += "   End"+CRLF
cQuery += "   Close CUR_SEQIDX"+CRLF
cQuery += "   Deallocate CUR_SEQIDX"+CRLF
cQuery += "   Select @OUT_RESULT = '1'"+CRLF
cQuery += "end"+CRLF

cQuery := MsParse(cQuery, If(Upper(TcSrvType())= "ISERIES", "DB2", Alltrim(TcGetDB())))

//Efetua tratamento para o DB2
If Trim(TcGetDb()) = 'DB2'
	cQuery	:= StrTran( cQuery, 'set vfim_CUR  = 0 ;', 'set fim_CUR = 0;' )
EndIf

Return( cQuery )

