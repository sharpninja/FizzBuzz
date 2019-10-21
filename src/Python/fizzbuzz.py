print('\n'.join(['Fizz' * (not i % 3) + 'Buzz' * (not i % 5) or str(i) for i in range(1, 101)]))
