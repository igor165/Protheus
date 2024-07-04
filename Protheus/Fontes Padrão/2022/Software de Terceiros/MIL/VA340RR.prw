#INCLUDE "PROTHEUS.CH"

User Function VA340RR()

///Local cCodcli := ParamIXB[1]
Local aRR := {} 
Local cAliasVMK := "SQLVMK"    
Local cAliasVML := "SQLVML"    
Local cAliasVMS := "SQLVMS"     
Local cAliasVMT := "SQLVMT"     
Local cAliasVMQ := "SQLVMQ"     
Local aRet := {}

cDat := year(ddatabase)
aParamBox := {}
AADD(aParamBox,{1,"Ano Base",cDat,"@!","!Empty(MV_PAR01)","",,50,.f.}) // Data
if !ParamBox(aParamBox,"",@aRet,,,,,,,,.T.) 
   Return(.f.)
Endif    
M_RENAGR := 0 // Receita Agropecuária Bruta - RAB
M_OUTREN := 0 // Outras Receitas
M_RANOPB := 0 // Receita Operacional Bruta - ROB
M_INTEG   := 0
cAno := Alltrim(str(year(ddatabase)-1))                            

   
cQuery := "SELECT VMK.VMK_PRODUC,VMK.VMK_VUNIVD " 
cQuery += "FROM "
cQuery += RetSqlName( "VMK" ) + " VMK " 
cQuery += "WHERE " 
cQuery += "VMK.VMK_FILIAL='"+ xFilial("VMK")+ "' AND VMK.VMK_ANO = '"+Alltrim(str(aRet[1]))+"' AND VMK.VMK_CODCLI = '"+SA1->A1_COD+"' AND "
cQuery += "VMK.D_E_L_E_T_=' '"                                             

dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasVMK, .T., .T. )

Do While !( cAliasVMK )->( Eof() )
                             
    M_RENAGR += ( ( cAliasVMK )->VMK_PRODUC * ( cAliasVMK )->VMK_VUNIVD)

    dbSelectArea(cAliasVMK)
    ( cAliasVMK )->(dbSkip())
    
Enddo    
( cAliasVMK )->( dbCloseArea() )

cQuery := "SELECT VML.VML_ANIVDA,VML.VML_PRMDVD,VML.VML_OUTREC,VML.VML_ESPECI,VML.VML_QTDMAT,VML.VML_QTDLTD,VML.VML_PMDLIT, VML.VML_VACLAC "
cQuery += "FROM "
cQuery += RetSqlName( "VML" ) + " VML " 
cQuery += "WHERE " 
cQuery += "VML.VML_FILIAL='"+ xFilial("VML")+ "' AND VML.VML_ANO = '"+Alltrim(str(aRet[1]))+"' AND VML.VML_CODCLI = '"+SA1->A1_COD+"' AND "
cQuery += "VML.D_E_L_E_T_=' '"                                             

dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasVML, .T., .T. )

Do While !( cAliasVML )->( Eof() )
                             
    if ( cAliasVML )->VML_ESPECI <> "1"
	    M_RENAGR += ( (( cAliasVML )->VML_ANIVDA * ( cAliasVML )->VML_PRMDVD) + ( cAliasVML )->VML_OUTREC )
	Else
	    M_RENAGR += ( cAliasVML )->VML_VACLAC * ( cAliasVML )->VML_QTDLTD * 360 * ( cAliasVML )->VML_PMDLIT
	Endif    

    dbSelectArea(cAliasVML)
    ( cAliasVML )->(dbSkip())
    
Enddo    
( cAliasVML )->( dbCloseArea() )

cQuery := "SELECT VMT.VMT_VALLIQ,VMT.VMT_QTDANI "
cQuery += "FROM "
cQuery += RetSqlName( "VMT" ) + " VMT " 
cQuery += "WHERE " 
cQuery += "VMT.VMT_FILIAL='"+ xFilial("VMT")+ "' AND VMT.VMT_CODCLI = '"+SA1->A1_COD+"' AND "
cQuery += "VMT.D_E_L_E_T_=' '"                                             

dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasVMT, .T., .T. )

Do While !( cAliasVMT )->( Eof() )
                             
    M_RENAGR += ( cAliasVMT )->VMT_VALLIQ

    dbSelectArea(cAliasVMT)
    ( cAliasVMT )->(dbSkip())
    
Enddo    
( cAliasVMT )->( dbCloseArea() )


cQuery := "SELECT VMS.VMS_RECANO "
cQuery += "FROM "
cQuery += RetSqlName( "VMS" ) + " VMS " 
cQuery += "WHERE " 
cQuery += "VMS.VMS_FILIAL='"+ xFilial("VMS")+ "' AND VMS.VMS_ANO = '"+Alltrim(str(aRet[1]))+"' AND VMS.VMS_CODCLI = '"+SA1->A1_COD+"' AND "
cQuery += "VMS.D_E_L_E_T_=' '"                                             

dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasVMS, .T., .T. )

Do While !( cAliasVMS )->( Eof() )
                             
    M_OUTREN += (( cAliasVMS )->VMS_RECANO)

    dbSelectArea(cAliasVMS)
    ( cAliasVMS )->(dbSkip())
    
Enddo    
( cAliasVMS )->( dbCloseArea() )
        
cQuery := "SELECT VMQ.VMQ_RECTTA " 
cQuery += "FROM "
cQuery += RetSqlName( "VMQ" ) + " VMQ " 
cQuery += "WHERE " 
cQuery += "VMQ.VMQ_FILIAL='"+ xFilial("VMQ")+ "' AND VMQ.VMQ_CODCLI = '"+SA1->A1_COD+"' AND "
cQuery += "VMQ.D_E_L_E_T_=' '"                                             

dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasVMQ, .T., .T. )

Do While !( cAliasVMQ )->( Eof() )
                             
    M_OUTREN += ( cAliasVMQ )->VMQ_RECTTA

    dbSelectArea(cAliasVMQ)
    ( cAliasVMQ )->(dbSkip())
    
Enddo    
( cAliasVMQ )->( dbCloseArea() )

M_RANOPB := M_RENAGR + M_OUTREN 

Aadd(aRR,{"Renda Agropecuária Bruta",M_RENAGR})
Aadd(aRR,{"Outras Rendas",M_OUTREN})
Aadd(aRR,{"Renda Operacional Bruta",M_RANOPB})

DEFINE MSDIALOG oDlgF FROM 000,000 TO 028,054 TITLE "Resumo da Renda" OF oMainWnd
        
	@ 010,005 SAY ("Código"+":") SIZE 50,8 OF oDlgF PIXEL COLOR CLR_BLUE // Codigo
	@ 009,030 MSGET oCodCli VAR SA1->A1_COD PICTURE "@!" SIZE 35,08 OF oDlgF PIXEL COLOR CLR_BLUE WHEN .f.
	@ 010,085 SAY ("Nome"+":") SIZE 50,8 OF oDlgF PIXEL COLOR CLR_BLUE // Nome
	@ 009,110 MSGET oNomCli VAR SA1->A1_NOME PICTURE "@!" SIZE 100,08 OF oDlgF PIXEL COLOR CLR_BLUE WHEN .f.

	@ 023,012 SAY "OBS:  RAB (Renda Agropecuária Bruta) e ROB (Renda Operacional Bruta)" SIZE 350,8 OF oDlgF PIXEL COLOR CLR_BLUE 
	@ 033,012 SAY "se referem às receitas auferidas no ano anterior." SIZE 350,8 OF oDlgF PIXEL COLOR CLR_BLUE 
	@ 043,012 SAY "Quando estiver iniciando na Atividade, informar RAB projetada para a 1ª Safra." SIZE 350,8 OF oDlgF PIXEL COLOR CLR_BLUE 
	    
    @ 055,003 LISTBOX oLbx1 FIELDS HEADER "Descrição","Valor" COLSIZES 140,20 SIZE 210,138 OF oDlgF PIXEL 
    oLbx1:SetArray(aRR)
   	oLbx1:bLine := { || {aRR[oLbx1:nAt,1],;
   						 FG_AlinVlrs(Transform(aRR[oLbx1:nAt,2],"@E 999,999,999.99"))}} 
   						 
   DEFINE SBUTTON FROM 197,180 TYPE 2 ACTION (oDlgF:End()) ENABLE OF oDlgF
	   						 
	   	
ACTIVATE MSDIALOG oDlgF CENTER 

Return()
