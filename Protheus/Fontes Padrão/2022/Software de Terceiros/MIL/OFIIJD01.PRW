// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 03     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#Include "Protheus.ch"
#Include "OFIIJD01.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OFIIJD01 ³ Autor ³  Thiago					  ³ Data ³ 22/12/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Importação DEF.						                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIIJD01()
Local aParamBox  := {}           
Local aRet       := {}                                    
Local nOpcGetFil := GETF_LOCALHARD + GETF_NETWORKDRIVE
Local cAliasVD8  := "SQLVD8"
Local cAliasVD9  := "SQLVD9"
Local	cVD9ConCta := ""
Local	cVD9Descri := ""
Local	cVD9CpoDef := ""
Local	cVD9Ccusts := ""
Local	cVDECctErp := "" 
Local cCodCon    := ""
Local	cVDEOper	  := ""
Local	cVDETipSal := ""
Local	cVDECcusto := "" 
Local _n         := 0

aAdd(aParamBox,{1,RetTitle("VD9_CODDEF"),Space(TamSX3("VD9_CODDEF")[1]),"@!","","VD7","",0,.T.}) 
aAdd(aParamBox,{6,"Arquivo:",Space(200),"","","",80,	.T.,"(*.csv) |*.csv",,nOpcGetFil})
	
If !(ParamBox(aParamBox,"",@aRet,,,,,,,,.f.,.t.))
	Return .f.
EndIf

If !MsgYesNo(STR0001,STR0002) //Esta rotina irá importar dados externos para a criação automatizada do cadastro dos itens do DEF! Deseja continuar?
	Return .f.
EndIf


If File(aRet[2])
	
	if (nHandle:= FT_FUse( aRet[2] )) == -1
		Return
	EndIf
	
	FT_FGotop()
	lRet := .f.
	While ! FT_FEof()
		
		cStr := FT_FReadLN()
		If !Empty(cStr)

  	      For _n := 1 to Len(cStr)
	  	      nPosAt := AT(";",cStr)
				if nPosAt > 0
					nPosAt -= 1
				Else
					nPosAt := Len(cStr)
				Endif  
				if Empty(cStr)
					Exit
				Endif	
				Do Case
					Case _n == 1
						cVD9ConCta := alltrim(Substr(cStr,1,nPosAt)) // Código da Conta Contábil na John Deere	   
						if alltrim(Substr(cVD9ConCta,1,1)) == '"' 
							cVD9ConCta := alltrim(Substr(cVD9ConCta,2,Len(cVD9ConCta)))
						Endif	
						if alltrim(Substr(cVD9ConCta,Len(cVD9ConCta),1)) == '"' 
							cVD9ConCta := alltrim(Substr(cVD9ConCta,1,Len(cVD9ConCta)-1))
						Endif	
					Case _n == 2
						cVD9Descri := alltrim(Substr(cStr,1,nPosAt)) // Descrição da Conta Contábil na John  Deer	  
						if alltrim(Substr(cVD9Descri,Len(cVD9Descri),1)) == '"' 
							cVD9Descri := alltrim(Substr(cVD9Descri,1,Len(cVD9Descri)-1))
						Endif	
					Case _n == 3
						cVD9CpoDef := alltrim(Substr(cStr,1,nPosAt)) // Campo DEF	   
						if alltrim(Substr(cVD9CpoDef,Len(cVD9CpoDef),1)) == '"' 
							cVD9CpoDef := alltrim(Substr(cVD9CpoDef,1,Len(cVD9CpoDef)-1))
						Endif	
					Case _n == 4
						cVD9Ccusts := alltrim(Substr(cStr,1,nPosAt)) // Centros de Custos (separados por vírgula)
						if alltrim(Substr(cVD9Ccusts,Len(cVD9Ccusts),1)) == '"' 
							cVD9Ccusts := alltrim(Substr(cVD9Ccusts,1,Len(cVD9Ccusts)-1))
						Endif	
					Case _n == 5
						cVDECctErp := alltrim(Substr(cStr,1,nPosAt)) // Código da Conta Contábil no ERP
						if alltrim(Substr(cVDECctErp,Len(cVDECctErp),1)) == '"' 
							cVDECctErp := alltrim(Substr(cVDECctErp,1,Len(cVDECctErp)-1))
						Endif	
					Case _n == 6
						cVDEOper := alltrim(Substr(cStr,1,nPosAt)) // Operação 1=Soma / 2=Subtrai
						if alltrim(Substr(cVDEOper,Len(cVDEOper),1)) == '"' 
							cVDEOper := alltrim(Substr(cVDEOper,1,Len(cVDEOper)-1))
						Endif	
					Case _n == 7
						cVDETipSal := alltrim(Substr(cStr,1,nPosAt)) // Tipo de Saldo 1=Saldo Atual / 2=Débito da Data
						if alltrim(Substr(cVDETipSal,Len(cVDETipSal),1)) == '"' 
							cVDETipSal := alltrim(Substr(cVDETipSal,1,Len(cVDETipSal)-1))
						Endif	
					Case _n == 8  
						cVDECcusto := alltrim(Substr(cStr,1,nPosAt)) // Centro Custo. Quando informado sobrepõe Centros de Custos  (VD9Ccusts )	   
						if alltrim(Substr(cVDECcusto,Len(cVDECcusto),1)) == '"' 
							cVDECcusto := alltrim(Substr(cVDECcusto,1,Len(cVDECcusto)-1))
						Endif	
				
				EndCase
				cStr := alltrim(Substr(cStr,nPosAt+2,Len(cStr)))
			Next  

			cCodCon := GetSXENum("VD9","VD9_CODCON")
				
			
			// Gravacao da tabela VD9
			dbSelectArea("VD9")  
			RecLock("VD9",.t.)
			VD9->VD9_CODDEF := aRet[1]
			VD9->VD9_CPODEF := cVD9CpoDef
			VD9->VD9_CODCON :=  cCodCon
			VD9->VD9_CONCTA := cVD9ConCta
			VD9->VD9_DESCRI := cVD9Descri
			VD9->VD9_CCUSTS := cVD9Ccusts
			VD9->VD9_TIPO   := "3"
			VD9->VD9_ATIVO  := "1"
			ConfirmSX8()
			MsUnlock()                 

			//Gravação da tabela VDE
			dbSelectArea("VDE")  
			dbSetOrder(1)
			lAchou := dbSeek(xFilial("VDE")+aRet[1]+VD9->VD9_CODCON)  
			RecLock("VDE",!lAchou)
			VDE->VDE_CODDEF := VD9->VD9_CODDEF
			VDE->VDE_CODCON := VD9->VD9_CODCON 
			VDE->VDE_CCTERP := cVDECctErp
			VDE->VDE_OPER   := cVDEOper
			VDE->VDE_TIPSAL := cVDETipSal
			VDE->VDE_CCUSTO := cVDECcusto
		EndIf

		FT_FSkip()
	End
	FT_FUse()

Endif

// Gravacao da tabela VDA
cQuery := "SELECT DISTINCT VD9.VD9_CODDEF,VD9.VD9_CODCON,VD8.VD8_CODDEF,VD8.VD8_CODEMP,VD8.VD8_CODFIL,VD8.VD8_ATIVO "
cQuery += "FROM "
cQuery += RetSqlName( "VD8"  ) + " VD8 " 
cQuery += "JOIN "+RetSqlName("VD9")+" VD9 ON ( VD9.VD9_FILIAL='"+xFilial("VD9")+"' AND VD9.VD9_CODDEF=VD8.VD8_CODDEF AND VD9.D_E_L_E_T_ = ' ' ) "
cQuery += "WHERE " 
cQuery += "VD8.VD8_FILIAL='"+ xFilial("VD8")+ "' AND VD8.VD8_CODDEF = '"+aRet[1]+"' AND "
cQuery += "VD8.D_E_L_E_T_=' '"                                             

dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasVD8, .T., .T. )

Do While !( cAliasVD8 )->( Eof() )
	dbSelectArea("VDA")
	dbSetOrder(1)
	if !dbSeek(xFilial("VDA")+( cAliasVD8 )->VD9_CODDEF+( cAliasVD8 )->VD9_CODCON+( cAliasVD8 )->VD8_CODEMP+( cAliasVD8 )->VD8_CODFIL)
		RecLock("VDA",.t.)
		VDA->VDA_CODDEF := ( cAliasVD8 )->VD9_CODDEF
		VDA->VDA_CODCON := ( cAliasVD8 )->VD9_CODCON
		VDA->VDA_CODEMP := ( cAliasVD8 )->VD8_CODEMP  
		VDA->VDA_CODFIL := ( cAliasVD8 )->VD8_CODFIL     
		VDA->VDA_ATIVO  := ( cAliasVD8 )->VD8_ATIVO       
	   MsUnlock()                 
   Endif
	dbSelectArea(cAliasVD8)
	( cAliasVD8 )->(dbSkip())
	
Enddo
( cAliasVD8 )->( dbCloseArea() )
  
MsgInfo(STR0003)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OIJD01EXP ³ Autor ³ Thiago					  ³ Data ³ 22/12/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Exportacao DEF.						                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OIJD01EXP() 
Local aParamBox := {}          
Local aRet      := {}
Local aIntCab   := {} 
Local aIntIte   := {}  
Local cAliasVD9 := "SQLVD9"
Local cNomRel   := "OFIIJD01"  
Local cTitulo   := STR0004

aAdd(aParamBox,{1,RetTitle("VD9_CODDEF"),Space(TamSX3("VD9_CODDEF")[1]),"@!","","VD7","",0,.T.}) 
	
If !(ParamBox(aParamBox,"",@aRet,,,,,,,,.f.,.t.))
	Return .f.
EndIf


aAdd(aIntCab,{STR0005,"C",6,"@!"})
aAdd(aIntCab,{STR0006,"C",6,"@!"})
aAdd(aIntCab,{STR0007,"C",50,"@!"})
aAdd(aIntCab,{STR0008,"C",150,"@!"})
aAdd(aIntCab,{STR0009,"C",6,"@!"})
aAdd(aIntCab,{STR0010,"C",250,"@!"})
aAdd(aIntCab,{STR0011,"C",1,"@!"})
aAdd(aIntCab,{STR0012,"C",1,"@!"})
aAdd(aIntCab,{STR0013,"C",20,"@!"})
aAdd(aIntCab,{STR0017,"C",80,"@!"})
aAdd(aIntCab,{STR0014,"C",1,"@!"})
aAdd(aIntCab,{STR0015,"C",1,"@!"})
aAdd(aIntCab,{STR0016,"C",9,"@!"})


cQuery := "SELECT VD9.VD9_CODDEF,VD9.VD9_CODCON,VD9.VD9_CONCTA,VD9.VD9_DESCRI,VD9.VD9_CPODEF,VD9.VD9_CCUSTS,VD9.VD9_TIPO,VD9.VD9_ATIVO,VDE.VDE_CCTERP,CT1.CT1_DESC01,VDE.VDE_OPER,VDE.VDE_TIPSAL,VDE.VDE_CCUSTO "
cQuery += "FROM "
cQuery += RetSqlName( "VD9"  ) + " VD9 " 
cQuery += " JOIN "+RetSqlName("VDE")+" VDE ON (VDE.VDE_FILIAL='"+xFilial("VDE")+"' "
cQuery += "AND VDE.VDE_CODDEF = VD9.VD9_CODDEF AND VDE.VDE_CODCON = VD9.VD9_CODCON AND VDE.D_E_L_E_T_=' ') "
cQuery += " LEFT JOIN "+RetSqlName("CT1")+" CT1 ON (CT1.CT1_FILIAL='"+xFilial("CT1")+"' AND CT1.CT1_CONTA = VDE.VDE_CCTERP AND CT1.D_E_L_E_T_=' ') "
cQuery += "WHERE " 
cQuery += "VD9.VD9_FILIAL='"+ xFilial("VD9")+ "' AND VD9.VD9_CODDEF = '"+aRet[1]+"' AND "
cQuery += "VD9.D_E_L_E_T_=' '"                                             

dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasVD9, .T., .T. )

Do While !( cAliasVD9 )->( Eof() )

	aAdd(aIntIte,{( cAliasVD9 )->VD9_CODDEF,( cAliasVD9 )->VD9_CODCON,( cAliasVD9 )->VD9_CONCTA,( cAliasVD9 )->VD9_DESCRI,( cAliasVD9 )->VD9_CPODEF,( cAliasVD9 )->VD9_CCUSTS,( cAliasVD9 )->VD9_TIPO,( cAliasVD9 )->VD9_ATIVO,( cAliasVD9 )->VDE_CCTERP,( cAliasVD9 )->CT1_DESC01,( cAliasVD9 )->VDE_OPER,( cAliasVD9 )->VDE_TIPSAL,( cAliasVD9 )->VDE_CCUSTO}) 

	dbSelectArea(cAliasVD9)
	( cAliasVD9 )->(dbSkip())
	
Enddo
( cAliasVD9 )->( dbCloseArea() )



FGX_VISINT(cNomRel , cTitulo , aIntCab , aIntIte , .f. )

Return
