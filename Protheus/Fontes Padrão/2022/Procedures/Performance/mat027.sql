Create Procedure MAT027_## (@IN_QTDORIG float output)

as

/* -------------------------------------------------------------------
    Versão      - <v> Protheus 12 </v>
    Programa    - <s> SP ORIGEM : MAT028 </s>
    Assinatura  - <a> 001 </a>
    Descricao   - <d> Retorna o argumento passado com um arredondamento padrao
                   versao anterior MATXFUNC.PRX (QtdComp) </d>

    Saida       - <ri> @IN_QTDORIG - Número a ser arredondado </ri>

    Responsavel - <r> Ricardo Gonçalves </r>
    Data        - <dt> 23.07.2001 </dt>
------------------------------------------------------------------- */
begin

  select @IN_QTDORIG = isnull( round( @IN_QTDORIG, 8 ), 0 )

end
