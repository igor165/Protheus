#INCLUDE "PONM400.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PONCALEN.CH"
#INCLUDE "SIGAWIN.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o  �fDelCal   �Autor �Igor Franzoi	  			  �Data�08/11/2007���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Deleta registros de calendario fisico para o funcionario	  ���
���			 �Esta funcao deleta os cabec. dos calend. (RF6), e faz uma   ���
���			 �chamada a outra funcao que delete os itens do calend. (RF7) ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �fDelCal()	                                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�															  ���
�������������������������������������������������������������������������Ĵ��
���Uso       �Generico                                                    ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���			   �		�	   �										  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
Function fDelCal( cFil, cMat, dDtaIni, dDtaFim )

    Local lRet   := .F.
    Local cAlias := "RF6"
    Local aArea  := GetArea()

    #IFNDEF TOP
        Local nOrderRf6  
    #ENDIF
    Local cQuery      := ""
    Local cFilter     := ""
    Local cFilRecno   := ""
    Local cAliasQry	  := ""
    Local cQueryDelet := ""
    Local cRetSqlName := InitSqlName(cAlias)
    Local cNameDB	  := ""

    Local nMinRec := 0
    Local nMaxRec := 0

    /*/
    �������������������������������������������������������������Ŀ
    �Caso nao tenha sido definido o tipo da variavel executa a    �
    �funcao novamente para setar o valor						  �
    ���������������������������������������������������������������/*/
    lSrvType := If( Type("lSrvType") == "U", TcSrvType() != "AS/400", lSrvType )

    /*
    ������������������������������������������������������������������������Ŀ
    �O banco DB2 nao aceita o nome da tabela apos o comando DELETE			 �
    ��������������������������������������������������������������������������*/
    cNameDB	:= Upper(TcGetDb())

    If lSrvType
        cDelet    := "% RF6.D_E_L_E_T_ = ' ' %"
        cCpoRecno := "R_E_C_N_O_"
    Else
        cDelet    := "% RF6.@DELETED@ = ' ' %"
        cCpoRecno := "RRN("+cRetSqlName+")"
    EndIf

    Begin Transaction

    #IFDEF TOP

        cAliasQry := GetNextAlias()

        If !Empty(dDtaFim)
            cFilter := " RF6.RF6_FILIAL = '"+cFil+"'"
            cFilter += " AND RF6.RF6_MAT = '"+cMat+"' "
            cFilter += " AND RF6.RF6_DATA >= '"+Dtos(dDtaIni)+"'"
            cFilter += " AND RF6.RF6_DATA <= '"+Dtos(dDtaFim)+"'"
        Else
            cFilter := " RF6.RF6_FILIAL = '"+cFil+"'"
            cFilter += " AND RF6.RF6_MAT = '"+cMat+"' "
            cFilter += " AND RF6.RF6_DATA >= '"+Dtos(dDtaIni)+"'"
        EndIf
        
        cFilter := "%"+cFilter+"%"

        BeginSql alias cAliasQry
            column RF6_DATA	as Date
            %NoParser%
            SELECT 
                MAX(RF6_DATA) as RF6_DATA,
                MIN(RF6.R_E_C_N_O_) MINREC, 
                MAX(RF6.R_E_C_N_O_) MAXREC
            FROM 
                %Table:RF6% RF6
            WHERE 
                %Exp:cFilter% AND
                %Exp:cDelet%
        EndSql
        
        nMinRec := (cAliasQry)->(MINREC)
        nMaxRec := (cAliasQry)->(MAXREC)

        If !Empty(nMinRec)
            /*/
            �������������������������������������������������������������Ŀ
            � Deleta os itens antes do cabecalho						  �
            ���������������������������������������������������������������/*/
            fDelCalIte( cFil, cMat, dDtaIni, dDtaFim )
                
            cQuery := "DELETE " 
        
            If !( cNameDB $ "DB2_ORACLE_INFORMIX_POSTGRES" )
                cQuery += cRetSqlName
            EndIf
        
            cQuery += " FROM " + cRetSqlName + " RF6 "
            
            While ( nMinRec <= nMaxRec )		
                cFilRecno := " WHERE "
                cFilRecno += " RF6." + cCpoRecno + " >= " + AllTrim( Str( nMinRec , 18 , 0 ) )
                cFilRecno += " AND "
                cFilRecno += " RF6." + cCpoRecno + " <= " + AllTrim( Str( ( nMinRec += 1024 ) , 18 , 0 ) )     
                cFilRecno += " AND "
                cQueryDelet := ( cQuery + cFilRecno + SubStr( AllTrim(cFilter), 3,Len(AllTrim(cFilter))-3 ) )

                TcSqlExec( cQueryDelet )
            End While
            
            TcRefresh( cRetSqlName )
            lRet := .T.
        EndIf
        
        (cAliasQry)->( DbCloseArea() )
        
    #ELSE
        
        cAliasQry := cAlias
        nOrderRf6 := RetOrder(cAliasQry, "RF6_FILIAL+RF6_MAT+RF6_DATA+RF6_TURNO")

        /*/
        �������������������������������������������������������������Ŀ
        � Seleciona a area de trabalho								  �
        ���������������������������������������������������������������/*/
        dbSelectArea(cAliasQry)
        dbSetOrder(nOrderRf6)
        
        /*/
        �������������������������������������������������������������Ŀ
        � Posiciona no registro do funcionario						  �
        ���������������������������������������������������������������/*/
        (cAliasQry)->(MsSeek(cFil+cMat+Dtos(dDataIni),.T.))
        
        cPref := cAliasQry
        
        /*/
        �������������������������������������������������������������Ŀ
        � Deleta os itens antes do cabecalho						  �
        ���������������������������������������������������������������/*/	
        fDelCalIte( cFil, cMat, dDtaIni, dDtaFim )
        
        While (cAliasQry)->( !Eof() .and. &(cPref+"FILIAL")+&(cPref+"MAT") ==  cFil+cMat .and. ;
            (&(cPref+"DATA") >= Dtos(dDtaIni) .and. &(cPref+"DATA") <= Dtos(dDtaFim) ) )
            (cAliasQry)->(dbDelete())
            (cAliasQry)->(dbSkip())
        EndDo

        lRet := .T.
        
    #ENDIF

    End Transaction 

    RestArea(aArea)

Return lRet

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o  �fWriteCal �Autor �Igor Franzoi	  			  �Data�08/11/2007���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Chama a funcao de criacao do calendario 					  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �fWriteCal()                                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros� cFil      = Filial 					 					  ���
���	         � cMat 	 = Matriculas dos funcionarios para geracao       ���
���	         � dIniPer	 = Inicio do periodo atual						  ���
���	         � dFimPer   = Fim do periodo atual							  ���
�������������������������������������������������������������������������Ĵ��
���Uso       �Generico                                                    ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���			   �		�	   �										  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
Function fWriteCal( cFil,; 		//07 -> Filial atual do funcionario
					cMat,;      //08 -> Matricula atual
					cCC,;       //09 -> Centro de Custo
					cSeq,;      //04 -> Sequencia
					cTno,;      //03 -> Turno
					dIniPer,;   //01 -> Periodo inicial
					dFimPer,;   //02 -> Periodo final
					lDtaCal,; 	//17 -> .T. Caso exista calendario fisico 
					dIniCal,; 	//18 -> Data inicial do calendario fisico
					dFimCal  ) 	//19 -> Data final do calendario fisico	

    Local lRet  := .T.
    Local aArea := GetArea()

    Local lSncMaMe	  := NIL
    Local lForceNew	  := .T.
    Local lExecQryTop := NIL

    Local aTurnos
    Local aExcePer
    Local aTabPadrao
    Local aTabCalend
    Local aMarcacoes

    If ( Type("cAuxFilAnt") == "U" )
        cAuxFilAnt := ""
    EndIf

    If ( Type("aAuxError") == "U" )
        aAuxError := {}
    EndIf

    If ( Type("cRecCalend") == "U" )
        cRecCalend := ""
    EndIf


        /*/
        �������������������������������������������������������������Ŀ
        �Chama CriaCalend para geracao do calendario				  �
        ���������������������������������������������������������������/*/
        lRet := CriaCalend(	dIniPer		,; //01 -> Data Inicial do Periodo
                            dFimPer		,; //02 -> Data Final do Periodo
                            cTno		,; //03 -> Turno Para a Montagem do Calendario
                            cSeq		,; //04 -> Sequencia Inicial para a Montagem Calendario
                            @aTabPadrao	,; //05 -> Array Tabela de Horario Padrao
                            @aTabCalend	,; //06 -> Array com o Calendario de Marcacoes
                            cFil		,; //07 -> Filial para a Montagem da Tabela de Horario
                            cMat		,; //08 -> Matricula para a Montagem da Tabela de Horario
                            cCc			,; //09 -> Centro de Custo para a Montagem da Tabela
                            @aTurnos	,; //10 -> Array com as Trocas de Turno
                            @aExcePer	,; //11 -> Array com Todas as Excecoes do Periodo
                            lExecQryTop	,; //12 -> Se executa Query para a Montagem da Tabela Padrao
                            lSncMaMe	,; //13 -> Se executa a funcao se sincronismo do calendario
                            lForceNew	,; //14 -> Se Forca a Criacao de Novo Calendario
                            @aMarcacoes ,; //15 -> Array com marcacoes para tratamento de Turnos Opcionais
                            .T.			,; //16 -> .T. Determina a Criacao/Carga do Calendario Fisico  
                            lDtaCal		,; //17 -> .T. Caso exista calendario fisico 
                            dIniCal		,; //18 -> Data inicial do calendario fisico
                            dFimCal		,; //19 -> Data final do calendario fisico	
                            .T.			,; //20 -> .T. determina que o calendario sera gravado no caso de nao existir
                            .T.			 ; //21 -> .T. determina que a rotina chamadora eh a Geracao de Calendarios (PONM400)
                        )
        
        If !lRet
            If cAuxFilAnt <> cFil
                aAdd( aAuxError , { cRecCalend , STR0019 + " - " + cFil } )   //"Filial - XX"
                cAuxFilAnt := cFil
            EndIf
            aAdd( aAuxError , { cRecCalend , Space(2) + STR0014 + " " + cMat + " - " + STR0015 + " " + SRA->RA_NOME } )//"Matr�cula XX - Nome XXXXXXXXXXXXXXX"
            IF !Empty( oCalendError:aLogErrors )
                aAdd( aAuxError , oCalendError:aLogErrors[Len(oCalendError:aLogErrors)] )
            Endif
            oCalendError:aLogErrors := {}
            lErroCal := .T.
        EndIf
    RestArea( aArea )

Return lRet


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o  �fDatMaxCal�Autor �Igor Franzoi	  			  �Data�12/11/2007���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Verifica qual a data do ultimo calendario gerado para o 	  ���
���			 �funcionario 												  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �fDatMaxCal()                                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros� cFil = Filial do funcionario								  ���
���			 � cMat = Matricula do funcionario							  ���
�������������������������������������������������������������������������Ĵ��
���Uso       �Generico                                                    ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���			   �		�	   �										  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
Function fDatMaxCal( cFil, cMat, dDtaMax, dDtaMin )

    Local lRet	:= .F.	
    Local aArea := GetArea()

    Local cAlias 	  := "RF6"
    Local cFilter	  := ""

    #IFNDEF TOP
        Local nOrderRf6  
    #ELSE	
        Local cAliasQuery := cAlias
    #ENDIF	

    DEFAULT cFil := ""
    DEFAULT	cMat := ""
    DEFAULT dDtaMax := dDataBase
    DEFAULT dDtaMin := dDataBase

    /*/
    �������������������������������������������������������������Ŀ
    �Caso nao tenha sido definido o tipo da variavel executa a    �
    �funcao novamente para setar o valor						  �
    ���������������������������������������������������������������/*/
    lSrvType := If( Type("lSrvType") == "U", TcSrvType() != "AS/400", lSrvType )

    If lSrvType
        cDelet    := "% RF6.D_E_L_E_T_ = ' ' %"
        cCpoRecno := "R_E_C_N_O_"
    Else
        cDelet    := "% RF6.@DELETED@ = ' ' %"
        cCpoRecno := "RRN("+cRetSqlName+")"
    EndIf

    #IFDEF TOP
        
        cAliasQuery := GetNextAlias()

        cFilter := " RF6_FILIAL = '"+cFil+"'"
        cFilter += " AND RF6_MAT = '"+cMat+"'"
        cFilter := "%"+cFilter+"%"

        BeginSql alias cAliasQuery
            column MINDTA as Date, MAXDTA as Date
            %NoParser%
            SELECT 
                MIN(cAliasQuery.RF6_DATA) MINDTA, 
                MAX(cAliasQuery.RF6_DATA) MAXDTA
            FROM 
                %Table:RF6% cAliasQuery
            WHERE 
                %Exp:cFilter%
        EndSql
        
        dDtaMax := (cAliasQuery)->(MAXDTA)
        dDtaMin := (cAliasQuery)->(MINDTA)
        
        If !Empty(dDtaMax) .or. !Empty(dDtaMin)
            lRet := .T.
        EndIf
        
        (cAliasQuery)->(dbCloseArea())
        
    #ELSE

        cFilter := cFil
        cFilter += cMat
        
        nOrderRf6 := (cAlias)->(dbSetOrder(RetOrder("RF6_FILIAL+RF6_MAT+DTOS(RF6_DATA)+RF6_TURNO")))

        dbSelectArea(cAlias)
        dbSetOrder(nOrderRf6)
        
        (cAlias)->(dbSeek( cFilter, .F. ))
        
        If Found()
            dDtaMin := (cAlias)->(RF6_DATA)
            lRet := .T.
        EndIf

        //Posiciona no registro acima da ultima ocorrencia possivel para a chave
        //Retrocede 1 reg para posicionar na maior ocorrencia.
        (cAlias)->(dbSeek( cFilter + "ZZZZZZZZ", .T. ))
        (cAlias)->(dbSkip(-1))
        dDtaMax := (cAlias)->(RF6_DATA)
        lRet	:= !Empty(dDtaMax)

    #ENDIF

    RestArea( aArea )

Return lRet

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o  �fDelCalIte�Autor �Igor Franzoi	  			  �Data�08/11/2007���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Deleta registros de calendario fisico para o funcionario	  ���
���			 �Esta funcao deleta os itens. dos calend. (RF7)			  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �fDelCalIte()                                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros�															  ���
�������������������������������������������������������������������������Ĵ��
���Uso       �Generico                                                    ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���			   �		�	   �										  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
Static Function fDelCalIte( cFil, cMat, dDtaIni, dDtaFim )

Local lRet   := .T.
Local cAlias := "RF7"

Local cQuery      := ""
Local cFilter     := ""
Local cFilRecno   := ""
Local cAliasQry   := ""
Local cQueryDelet := ""
Local cRetSqlName := InitSqlName(cAlias)
Local cNameDb	  := ""

Local nMinRec := 0
Local nMaxRec := 0

/*
������������������������������������������������������������������������Ŀ
�O banco DB2 nao aceita o nome da tabela apos o comando DELETE			 �
��������������������������������������������������������������������������*/
cNameDB	:= Upper(TcGetDb())

cDelet    := "% RF7.D_E_L_E_T_ = ' ' %"
cCpoRecno := "R_E_C_N_O_"

If !Empty(dDtaFim)
    cFilter := " RF7.RF7_FILIAL = '"+cFil+"'"
    cFilter += " AND RF7.RF7_MAT = '"+cMat+"'"
    cFilter += " AND RF7.RF7_DATA >= '"+Dtos(dDtaIni)+"'"
    cFilter += " AND RF7.RF7_DATA <= '"+Dtos(dDtaFim)+"'"
Else
    cFilter := " RF7.RF7_FILIAL = '"+cFil+"'"
    cFilter += " AND RF7.RF7_MAT = '"+cMat+"'"
    cFilter += " AND RF7.RF7_DATA >= '"+Dtos(dDtaIni)+"'"	
EndIf

cAliasQry := GetNextAlias()
cFilter   := "%"+cFilter+"%"

BeginSql alias cAliasQry
    column RF7_DATA as Date
    %NoParser%
    SELECT  
        MAX(RF7_DATA) as RF7_DATA,
        MIN(RF7.R_E_C_N_O_) MINREC, 
        MAX(RF7.R_E_C_N_O_) MAXREC
    FROM 
        %Table:RF7% RF7
    WHERE 
        %Exp:cFilter% AND
        %Exp:cDelet%			
EndSql

nMinRec := (cAliasQry)->( MINREC )
nMaxRec := (cAliasQry)->( MAXREC )

cQuery := "DELETE " 

If !( cNameDB $ "DB2_ORACLE_INFORMIX_POSTGRES" )
    cQuery += cRetSqlName
EndIf

cQuery += " FROM " + cRetSqlName + " RF7 "
    
While ( nMinRec <= nMaxRec )

        cFilRecno := " WHERE "
        cFilRecno += " RF7." + cCpoRecno + " >= " + AllTrim( Str( nMinRec , 18 , 0 ) )
        cFilRecno += " AND "
        cFilRecno += " RF7." + cCpoRecno + " <= " + AllTrim( Str( ( nMinRec += 1024 ) , 18 , 0 ) )
        cFilRecno += " AND "
        cQueryDelet := ( cQuery + cFilRecno + SubStr( AllTrim(cFilter), 3,Len(AllTrim(cFilter))-3 ) )

        TcSqlExec( cQueryDelet )
End While

TcRefresh( cRetSqlName )	

(cAliasQry)->(dbCloseArea())

Return lRet
