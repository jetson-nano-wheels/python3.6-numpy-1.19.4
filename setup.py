from setuptools import setup, find_packages
from distutils.core import Extension
import pathlib

here = pathlib.Path(__file__).parent.resolve()

long_description = (here / 'README.md').read_text(encoding='utf-8')

setup(
    name='jetson-nano-numpy',
    version='0.0.1',
    description='Unofficial wheel of Numpy 1.19.4 for Python 3.6 on the Nvidia Jetson Nano.',
    url='https://github.com/jetson-nano-wheels/python3.6-numpy-1.19.4',
    author='austinjp',
    classifiers=[
        'Development Status :: 2 - Pre-Alpha',
        'Environment :: GPU :: NVIDIA CUDA :: 10.2',
        'Intended Audience :: Developers',
        'License :: OSI Approved :: GNU General Public License v3 (GPLv3)',
        'Natural Language :: English',
        'Operating System :: POSIX :: Linux',
        'Programming Language :: Python :: 3.6',
        'Topic :: Scientific/Engineering :: Artificial Intelligence',
        'Topic :: Software Development :: Libraries :: Python Modules',
        'Topic :: System :: Installation/Setup',
        'Topic :: System :: Software Distribution',
        'Topic :: System :: Systems Administration'
    ],
    package_dir={'': 'src'},
    packages=find_packages(where='src'),
    python_requires='>=3.6, <4',
    install_requires=[
        'numpy==1.19.4'
    ],

    # extras_require={
    #     'dev': ['pip>=21.2.4']
    # },

    package_data={},
    data_files=[],

    # To provide executable scripts, use entry points in preference to the
    # "scripts" keyword. Entry points provide cross-platform support and allow
    # `pip` to create the appropriate form of executable for the target
    # platform.
    #
    # For example, the following would provide a command called `sample` which
    # executes the function `main` from this package when invoked:
    # entry_points={  # Optional
    #     'console_scripts': [
    #         'sample=sample:main',
    #     ],
    # },

    project_urls={
        'Bug Reports': 'https://github.com/jetson-nano-wheels/python3.6-numpy-1.19.4/issues',
        'Source': 'https://github.com/jetson-nano-wheels/python3.6-numpy-1.19.4',
    },
)
